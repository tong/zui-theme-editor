let project = new Project('zui-theme-editor');
project.addSources('Sources');
project.addLibrary('Libraries/zui');
//project.addLibrary(`${process.env['ARMSDK']}/lib/zui`);
project.addAssets('Assets/color_wheel.png');
project.addAssets('Assets/jetbrains.ttf');
if (platform === Platform.HTML5) {
    project.addAssets('Assets/html5/**');
}
resolve(project);
