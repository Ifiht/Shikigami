#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <string.h>
#include <piper.h>
#include "beanstalk-client/beanstalk.h"

int main(int argc, char *argv[]) {
    if (argc < 6) {
        fprintf(stderr, "Usage: %s <model.onnx> <model.onnx.json> <espeak-ng-data> <beanstalkd-host> <beanstalkd-port>\n", argv[0]);
        fprintf(stderr, "Connects to beanstalkd and synthesizes text from jobs in the 'tts' tube.\n");
        return 1;
    }

    char *model_path = argv[1];
    char *config_path = argv[2];
    char *espeak_data_path = argv[3];
    char *beanstalk_host = argv[4];
    int beanstalk_port = atoi(argv[5]);

    piper_synthesizer *synth = piper_create(model_path, config_path, espeak_data_path);

    if (!synth) {
        fprintf(stderr, "Failed to create Piper synthesizer\n");
        return 1;
    }


    int beanstalk_fd = bs_connect(beanstalk_host, beanstalk_port);
    if (beanstalk_fd == BS_STATUS_FAIL) {
        fprintf(stderr, "Failed to connect to beanstalkd at %s:%d\n", beanstalk_host, beanstalk_port);
        piper_free(synth);
        return 1;
    }

    if (bs_watch(beanstalk_fd, "tts") != BS_STATUS_OK) {
        fprintf(stderr, "Failed to watch 'tts' tube\n");
        bs_disconnect(beanstalk_fd);
        piper_free(synth);
        return 1;
    }

    if (bs_ignore(beanstalk_fd, "default") != BS_STATUS_OK) {
        fprintf(stderr, "Warning: Failed to ignore 'default' tube\n");
    }

    fprintf(stderr, "Connected to beanstalkd, waiting for jobs on 'tts' tube...\n");

    piper_synthesize_options options = piper_default_synthesize_options(synth);

    while (1) {
        BSJ *job = NULL;
        int status = bs_reserve(beanstalk_fd, &job);

        if (status != BS_STATUS_OK || !job) {
            fprintf(stderr, "Failed to reserve job: %s\n", bs_status_text(status));
            continue;
        }

        fprintf(stderr, "Processing job %" PRId64 ": %.*s\n", job->id, (int)job->size, job->data);

        piper_synthesize_start(synth, job->data, &options);

        piper_audio_chunk chunk;
        while (piper_synthesize_next(synth, &chunk) != PIPER_DONE) {
            for (size_t i = 0; i < chunk.num_samples; i++) {
                float sample = chunk.samples[i];
                if (sample > 1.0f) sample = 1.0f;
                if (sample < -1.0f) sample = -1.0f;
                int16_t s16_sample = (int16_t)(sample * 32767.0f);
                fwrite(&s16_sample, sizeof(int16_t), 1, stdout);
            }
            fflush(stdout);
        }

        bs_delete(beanstalk_fd, job->id);
        bs_free_job(job);
    }

    bs_disconnect(beanstalk_fd);

    piper_free(synth);

    return 0;
}
