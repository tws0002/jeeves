import pymel.core as pm
import mtoa.ui.ae.templates as templates
from mtoa.ui.ae.templates import AttributeTemplate, ShapeMixin, registerTranslatorUI
from mtoa.ui.ae.shaderTemplate import ShaderMixin

class pgYetiMayaTemplate(AttributeTemplate, ShapeMixin, ShaderMixin):
    def setup(self):
        self.commonShapeAttributes()
        self.addSeparator()
    
        self.addControl("aiMinPixelWidth")
        self.addControl("aiMode")

        self.addSeparator()
        self.addControl("aiDispHeight")
        self.addControl("aiDispPadding")
        self.addControl("aiDispZeroValue")
        self.addControl("aiDispAutobump")

        self.addAOVLayout()

templates.registerTranslatorUI(pgYetiMayaTemplate, "pgYetiMaya", "pgYetiArnoldMaya")
