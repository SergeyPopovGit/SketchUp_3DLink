# Loader for as_plugins/3ddesktop/3ddesktop.rb

#Стартовая точка для плагина объемного рабочего стола
#Все процедуры и функции находяться в объекте который обьявляеться и вызываеться из этого места

# load class for 3D Desktop work
 
require '3DDesktop/3DDesktop_class.rb'

load "3DDesktop/3DDesktop_class.rb"

D3 = Desktop3D.new

#@Desktop3D_Extentions = SketchupExtension.new("Desktop3D"),"su_examples/exampleScripts.rb")
#Desktop3D.new

	