# v1.1
# 8/10/11
#
# user presets for camera2 and cameraTracker film backs
# only works with Nuke 6.3v1 and above
# Install Instructions:
# 1. copy the file into your .nuke folder or anywhere in your NUKE_PATH 
# 2. in your init.py or menu.py put the following code:
# import cam_presets
# cam_presets.nodePresetCamera()
#
# Any issues or additional camera formats you would like added to this tool then email me
# dekekincaid@gmail.com

import nuke
def nodePresetCamera():
  nuke.setPreset("Camera2", "CCD/One Fourth Inch CCD 1.78", {'haperture': '3.5', 'label': 'One Fourth Inch CCD', 'note_font': 'Helvetica', 'vaperture': '2'})
  nuke.setPreset("Camera2", "CCD/One Third Inch CCD 1.78", {'haperture': '5.2', 'label': 'One Third Inch CCD', 'note_font': 'Helvetica', 'vaperture': '2.9'})
  nuke.setPreset("Camera2", "CCD/Half Inch CCD 1.78", {'haperture': '7', 'label': 'Half Inch CCD 1.78', 'note_font': 'Helvetica', 'vaperture': '3.9'})
  nuke.setPreset("Camera2", "CCD/Two 3rd Inch CCD 1.78", {'haperture': '9.59', 'label': 'Two 3rd Inch CCD 1.78', 'note_font': 'Helvetica', 'vaperture': '5.39'})
  nuke.setPreset("Camera2", "CCD/Two 3rd Inch CCD 2.40", {'haperture': '9.11', 'label': 'Two 3rd Inch CCD 2.40', 'note_font': 'Helvetica', 'vaperture': '3.81'})
  nuke.setPreset("Camera2", "CCD/Four Third Inch CCD", {'haperture': '17.3', 'label': 'Four Third Inch CCD', 'note_font': 'Helvetica', 'vaperture': '13'})
  nuke.setPreset("Camera2", "Arri Alexa", {'haperture': '23.76', 'label': 'Arri Alexa', 'note_font': 'Helvetica', 'vaperture': '13.365'})
  nuke.setPreset("Camera2", "Canon/1D MKIV Still", {'haperture': '27.9', 'label': 'Canon/1D MKIV Still', 'note_font': 'Helvetica', 'vaperture': '18.6'})
  nuke.setPreset("Camera2", "Canon/1D MKIV Video", {'haperture': '27.9', 'label': 'Canon 1D MKIV Video', 'note_font': 'Helvetica', 'vaperture': '15.7'})
  nuke.setPreset("Camera2", "Canon/5D MKII Still", {'haperture': '36', 'label': 'Canon 5D MKII Still', 'note_font': 'Helvetica', 'vaperture': '24'})
  nuke.setPreset("Camera2", "Canon/5D MKII Video", {'haperture': '36', 'label': 'Canon 5D MKII Video', 'note_font': 'Helvetica', 'vaperture': '20.3'})
  nuke.setPreset("Camera2", "Canon/7D Still", {'haperture': '22.3', 'label': 'Canon 7D Still', 'note_font': 'Helvetica', 'vaperture': '14.9'})
  nuke.setPreset("Camera2", "Canon/7D Video", {'haperture': '22.3', 'label': 'Canon 7D Video', 'note_font': 'Helvetica', 'vaperture': '12.5'})
  nuke.setPreset("Camera2", "Film/16mm 1.37", {'haperture': '10.26', 'label': '16mm 1.37', 'note_font': 'Helvetica', 'vaperture': '7.49'})
  nuke.setPreset("Camera2", "Film/Super 16mm 1.66", {'haperture': '12.35', 'label': 'Super 16mm 1.66', 'note_font': 'Helvetica', 'vaperture': '7.49'})
  nuke.setPreset("Camera2", "Film/35mm Full Frame", {'haperture': '36', 'label': '35mm Full Frame', 'note_font': 'Helvetica', 'vaperture': '18.3'})
  nuke.setPreset("Camera2", "Film/65mm 2.20", {'haperture': '52.63', 'label': '65mm 2.20', 'note_font': 'Helvetica', 'vaperture': '23.01'})
  nuke.setPreset("Camera2", "Film/Panavision Super 70mm", {'haperture': '48.56', 'label': 'Panavision Super 70mm', 'note_font': 'Helvetica', 'vaperture': '22.1'})
  nuke.setPreset("Camera2", "Film/70mm Extract 2.40", {'haperture': '48.56', 'label': '70mm Extract 2.40', 'note_font': 'Helvetica', 'vaperture': '20.31'})
  nuke.setPreset("Camera2", "Film/70mm Imax", {'haperture': '70', 'label': '70mm Imax', 'note_font': 'Helvetica', 'vaperture': '48.5'})
  nuke.setPreset("Camera2", "Film/Academy", {'haperture': '21.95', 'label': 'Academy', 'note_font': 'Helvetica', 'vaperture': '16'})
  nuke.setPreset("Camera2", "Film/Super35", {'haperture': '24.89', 'label': 'Super35', 'note_font': 'Helvetica', 'vaperture': '18.66'})
  nuke.setPreset("Camera2", "Film/35mm/2 perf 1.78", {'haperture': '15.6', 'label': '35mm 2 perf 1.78', 'note_font': 'Helvetica', 'vaperture': '8.76'})
  nuke.setPreset("Camera2", "Film/35mm/2 perf 2.40 v1", {'haperture': '22.05', 'label': '35mm 2 perf 2.40 v1', 'note_font': 'Helvetica', 'vaperture': '9.27'})
  nuke.setPreset("Camera2", "Film/35mm/2 perf 2.40 v2", {'haperture': '20.96', 'label': '35mm 2 perf 2.40 v2', 'note_font': 'Helvetica', 'vaperture': '8.76'})
  nuke.setPreset("Camera2", "Film/35mm/3 perf 1.78", {'haperture': '24.92', 'label': '35mm 3 perf 1.78', 'note_font': 'Helvetica', 'vaperture': '13.87'})
  nuke.setPreset("Camera2", "Film/35mm/4 perf 1.33 TV Safe", {'haperture': '20.12', 'label': '35mm 4 perf 1.33 TV Safe', 'note_font': 'Helvetica', 'vaperture': '15.09'})
  nuke.setPreset("Camera2", "Film/35mm/4 perf 1.33 Large TV Transmit", {'haperture': '21.13', 'label': '35mm/4 perf 1.33 Large TV Transmit', 'note_font': 'Helvetica', 'vaperture': '15.85'})
  nuke.setPreset("Camera2", "Film/35mm/4 perf 1.78", {'haperture': '24', 'label': '35mm 4 perf 1.78', 'note_font': 'Helvetica', 'vaperture': '13.5'})
  nuke.setPreset("Camera2", "Film/35mm/4 perf 1.85 Extract", {'haperture': '24', 'label': '35mm 4 perf 1.85 Extract', 'note_font': 'Helvetica', 'vaperture': '12.98'})
  nuke.setPreset("Camera2", "Film/35mm/4 perf 1.85 Projection", {'haperture': '20.96', 'label': '35mm 4 perf 1.85 Projection', 'note_font': 'Helvetica', 'vaperture': '11.33'})
  nuke.setPreset("Camera2", "Film/35mm/4 perf 2.40 Anamorphic Projection", {'haperture': '20.96', 'label': '35mm 4 perf 2.40 Anamorphic Projection', 'note_font': 'Helvetica', 'vaperture': '17.53'})
  nuke.setPreset("Camera2", "Film/35mm/4 perf 2.40 Extract", {'haperture': '20.96', 'label': '35mm 4 perf 2.40 Extract', 'note_font': 'Helvetica', 'vaperture': '10.4'})
  nuke.setPreset("Camera2", "Nikon/D3100", {'haperture': '22.3', 'label': 'Nikon D3100', 'note_font': 'Helvetica', 'vaperture': '12.5'})
  nuke.setPreset("Camera2", "Panasonic/AF100", {'haperture': '17.8', 'label': 'Panasonic AF100', 'note_font': 'Helvetica', 'vaperture': '10'})
  nuke.setPreset("Camera2", "Panasonic/GH2", {'haperture': '17.3', 'label': 'Panasonic GH2', 'note_font': 'Helvetica', 'vaperture': '13'})
  nuke.setPreset("Camera2", "Phantom/65", {'haperture': '51.2', 'label': 'Phantom 65', 'note_font': 'Helvetica', 'vaperture': '28.8'})
  nuke.setPreset("Camera2", "Phantom/Flex V640 16:9 2.5k", {'haperture': '25.6', 'label': 'Phantom Flex V640 16:9 2.5k', 'note_font': 'Helvetica', 'vaperture': '14.4'})
  nuke.setPreset("Camera2", "Phantom/Flex V640 16:9 1080p", {'haperture': '19.2', 'label': 'Phantom Flex V640 16:9 1080p', 'note_font': 'Helvetica', 'vaperture': '10.8'})
  nuke.setPreset("Camera2", "Phantom/Flex V640 16:9 720p", {'haperture': '12.8', 'label': 'Phantom Flex V640 16:9 720p', 'note_font': 'Helvetica', 'vaperture': '7.2'})
  nuke.setPreset("Camera2", "Phantom/HD Gold 16:9 2k", {'haperture': '25.6', 'label': 'Phantom HD Gold 16:9 2k', 'note_font': 'Helvetica', 'vaperture': '14.4'})
  nuke.setPreset("Camera2", "Phantom/HD Gold 16:9 1080p", {'haperture': '24', 'label': 'Phantom HD Gold 16:9 1080p', 'note_font': 'Helvetica', 'vaperture': '13.5'})
  nuke.setPreset("Camera2", "Phantom/HD Gold 16:9 720p", {'haperture': '16', 'label': 'Phantom HD Gold 16:9 720p', 'note_font': 'Helvetica', 'vaperture': '9'})
  nuke.setPreset("Camera2", "Red/5k", {'haperture': '27.65', 'label': 'Red 5k', 'note_font': 'Helvetica', 'vaperture': '13.82'})
  nuke.setPreset("Camera2", "Red/4.5k", {'haperture': '24.2', 'label': 'Red 4.5k', 'note_font': 'Helvetica', 'vaperture': '10.37'})
  nuke.setPreset("Camera2", "Red/4k", {'haperture': '22.2', 'label': 'Red 4k', 'note_font': 'Helvetica', 'vaperture': '12.6'})
  nuke.setPreset("Camera2", "Red/3k", {'haperture': '16.65', 'label': 'Red 3k', 'note_font': 'Helvetica', 'vaperture': '9.36'})
  nuke.setPreset("Camera2", "Red/2k", {'haperture': '11.1', 'label': 'Red 2k', 'note_font': 'Helvetica', 'vaperture': '6.24'})
  nuke.setPreset("Camera2", "Red/Epic S35", {'haperture': '30', 'label': 'Red Epic S35', 'note_font': 'Helvetica', 'vaperture': '15'})
  nuke.setPreset("Camera2", "Red/Epic FF35", {'haperture': '36', 'label': 'Red Epic FF35', 'note_font': 'Helvetica', 'vaperture': '24'})
  nuke.setPreset("Camera2", "Red/Epic 645", {'haperture': '56', 'label': 'Red Epic 645', 'note_font': 'Helvetica', 'vaperture': '42'})
  nuke.setPreset("Camera2", "Red/Epic 617", {'haperture': '168', 'label': 'Red Epic 617', 'note_font': 'Helvetica', 'vaperture': '56'})
  nuke.setPreset("Camera2", "Silicon Imaging/SI2k", {'haperture': '10.24', 'label': 'SI2k', 'note_font': 'Helvetica', 'vaperture': '5.76'})
  nuke.setPreset("Camera2", "Silicon Imaging/SI2k 1080p", {'haperture': '9.6', 'label': 'SI2k 1080p', 'note_font': 'Helvetica', 'vaperture': '5.4'})
  nuke.setPreset("Camera2", "Silicon Imaging/SI2k 720p", {'haperture': '6.4', 'label': 'SI2k 720p', 'note_font': 'Helvetica', 'vaperture': '3.6'})
  nuke.setPreset("Camera2", "Sony/F35 1.78", {'haperture': '23.62', 'label': 'Sony F35 1.78', 'note_font': 'Helvetica', 'vaperture': '13.28'})
  nuke.setPreset("Camera2", "Sony/F35 1.85", {'haperture': '22.45', 'label': 'Sony F35 1.85', 'note_font': 'Helvetica', 'vaperture': '12.14'})
  nuke.setPreset("Camera2", "Sony/F35 2.39", {'haperture': '22.45', 'label': 'Sony F35 2.39', 'note_font': 'Helvetica', 'vaperture': '9.4'})
  nuke.setPreset("Camera2", "Sony/F3", {'haperture': '24.7', 'label': 'Sony F3', 'note_font': 'Helvetica', 'vaperture': '13.1'})
  nuke.setPreset("Camera2", "Sony/EX1", {'haperture': '6.97', 'label': 'Sony EX1', 'note_font': 'Helvetica', 'vaperture': '2.92'})
  nuke.setPreset("CameraTracker1_0", "CCD/One Fourth Inch CCD 1.78", {'filmBackSize': '3.5 2', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "CCD/One Third Inch CCD 1.78", {'filmBackSize': '5.2 2.9', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "CCD/Half Inch CCD 1.78", {'filmBackSize': '7 3.9', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "CCD/Two 3rd Inch CCD 1.78", {'filmBackSize': '9.59 5.39', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "CCD/Two 3rd Inch CCD 2.40", {'filmBackSize': '9.11 3.81', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "CCD/Four Third Inch CCD", {'filmBackSize': '17.3 13', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Arri Alexa", {'filmBackSize': '23.76 13.365', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Canon/1D MKIV Still", {'filmBackSize': '27.9 18.6', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Canon/1D MKIV Video", {'filmBackSize': '27.9 15.7', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Canon/5D MKII Still", {'filmBackSize': '36 24', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Canon/5D MKII Video", {'filmBackSize': '36 20.3', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Canon/7D Still", {'filmBackSize': '22.3 14.9', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Canon/7D Video", {'filmBackSize': '22.3 12.5', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/16mm 1.37", {'filmBackSize': '10.26 7.49', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/Super 16mm 1.66", {'filmBackSize': '12.35 7.49', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/35mm Full Frame", {'filmBackSize': '36 18.3', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/65mm 2.20", {'filmBackSize': '52.63 23.01', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/Panavision Super 70mm", {'filmBackSize': '48.56 22.1', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/70mm Extract 2.40", {'filmBackSize': '48.56 20.31', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/70mm Imax", {'filmBackSize': '70 48.5', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/Academy", {'filmBackSize': '21.95 16', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/Super35", {'filmBackSize': '24.89 18.66', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/35mm/2 perf 1.78", {'filmBackSize': '15.6 8.76', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/35mm/2 perf 2.40 v1", {'filmBackSize': '22.05 9.27', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/35mm/2 perf 2.40 v2", {'filmBackSize': '20.96 8.76', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/35mm/3 perf 1.78", {'filmBackSize': '24.92 13.87', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/35mm/4 perf 1.33 TV Safe", {'filmBackSize': '20.12 15.09', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/35mm/4 perf 1.33 Large TV Transmit", {'filmBackSize': '21.13 15.85', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/35mm/4 perf 1.78", {'filmBackSize': '24 13.5', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/35mm/4 perf 1.85 Extract", {'filmBackSize': '24 12.98', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/35mm/4 perf 1.85 Projection", {'filmBackSize': '20.96 11.33', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/35mm/4 perf 2.40 Anamorphic Projection", {'filmBackSize': '20.96 17.53', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Film/35mm/4 perf 2.40 Extract", {'filmBackSize': '20.96 10.4', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Nikon/D3100", {'filmBackSize': '22.3 12.5', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Panasonic/AF100", {'filmBackSize': '17.8 10', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Panasonic/GH2", {'filmBackSize': '17.3 13', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Phantom/65", {'filmBackSize': '51.2 28.8', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Phantom/Flex V640 16:9 2.5k", {'filmBackSize': '25.6 14.4', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Phantom/Flex V640 16:9 1080p", {'filmBackSize': '19.2 10.8', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Phantom/Flex V640 16:9 720p", {'filmBackSize': '12.8 7.2', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Phantom/HD Gold 16:9 2k", {'filmBackSize': '25.6 14.4', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Phantom/HD Gold 16:9 1080p", {'filmBackSize': '24 13.5', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Phantom/HD Gold 16:9 720p", {'filmBackSize': '16 9', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Red/5k", {'filmBackSize': '27.65 13.82', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Red/4.5k", {'filmBackSize': '24.2 10.37', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Red/4k", {'filmBackSize': '22.2 12.6', 'selected': 'true', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Red/3k", {'filmBackSize': '16.65 9.36', 'selected': 'true', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Red/2k", {'filmBackSize': '11.1 6.24', 'selected': 'true', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Red/Epic S35", {'filmBackSize': '30 15', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Red/Epic FF35", {'filmBackSize': '36 24', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Red/Epic 645", {'filmBackSize': '56 42', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Red/Epic 617", {'filmBackSize': '168 56', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Silicon Imaging/SI 2k", {'filmBackSize': '10.24 5.76', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Silicon Imaging/SI 1080p", {'filmBackSize': '9.6 5.4', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Silicon Imaging/SI 720p", {'filmBackSize': '6.4 3.6', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Sony/F35 1.78", {'filmBackSize': '23.62 13.28', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Sony/F35 1.85", {'filmBackSize': '22.45 12.14', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Sony/F35 2.39", {'filmBackSize': '22.45 9.4', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Sony/F3", {'filmBackSize': '24.7 13.1', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
  nuke.setPreset("CameraTracker1_0", "Sony/EX1", {'filmBackSize': '6.97 2.92', 'serializeKnob': '22 serialization::archive 4 0 3 0 1 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0', 'selected': 'true', 'note_font': 'Helvetica', 'selectedRegion': '512 389 1536 1167'})
