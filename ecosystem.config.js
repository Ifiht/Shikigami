module.exports = {
  apps : [{
    name   : "beanstalk",
    script: './beanstalkd/beanstalkd',
    args: '-l 127.0.0.2 -p 9999'
  },
  {
    name   : "core.rb",
    script: 'ruby',
    args: './src/core.rb'
  }],

  deploy : {
    remote : {
      user : 'SSH_USERNAME',
      host : 'SSH_HOSTMACHINE',
      ref  : 'origin/main',
      repo : 'https://github.com/Ifiht/Shikigami.git',
      path : '$HOME/Shikigami',
      'pre-deploy-local': './init.sh',
      'post-deploy' : 'npm install pm2 -g && pm2 reload ecosystem.config.js --env production',
      'pre-setup': ''
    }
  }
};
