#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <piper.h>

int main(int argc, char *argv[]) {
    if (argc < 5) {
        fprintf(stderr, "Usage: %s <model.onnx> <model.onnx.json> <espeak-ng-data> <text>\n", argv[0]);
        return 1;
    }

    char *model_path = argv[1];
    char *config_path = argv[2];
    char *espeak_data_path = argv[3];
    char *text = argv[4];

    piper_synthesizer *synth = piper_create(model_path, config_path, espeak_data_path);

    if (!synth) {
        fprintf(stderr, "Failed to create Piper synthesizer\n");
        return 1;
    }


    piper_synthesize_options options = piper_default_synthesize_options(synth);

    piper_synthesize_start(synth, text, &options);

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

    piper_free(synth);

    return 0;
}
