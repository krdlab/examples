#!/usr/bin/env node

const yeoman   = require('yeoman-environment');
const memfs    = require('mem-fs');
const editor   = require('mem-fs-editor');
const inquirer = require('inquirer');
const path     = require('path');

const fs  = editor.create(memfs.create());
const env = yeoman.createEnv();

const res = env.lookup({
  packagePatterns: 'proto-cli',
  filePatterns: 'main.js'
});

const templateRoot    = path.join(res[0].packagePath, 'template');
const destinationRoot = process.cwd();
const templatePath    = file => path.join(templateRoot, file);
const destinationPath = file => path.join(destinationRoot, file);

const copyTemplate = context => {
  fs.copyTpl(
    templatePath('package.json'),
    destinationPath('package.json'),
    context
  );
  fs.copy(
    templatePath('index.js'),
    destinationPath('index.js')
  );
  fs.commit(() => console.log('initialized'));
};

inquirer.prompt([
  {
    name: 'name',
    message: 'package name',
    default: path.basename(__dirname)
  },
  {
    name: 'version',
    message: 'version',
    default: '0.1.0'
  },
  {
    name: 'description',
    message: 'description'
  },
  {
    name: 'author',
    message: 'author'
  }
]).then(answers => {
  copyTemplate(answers);
});
