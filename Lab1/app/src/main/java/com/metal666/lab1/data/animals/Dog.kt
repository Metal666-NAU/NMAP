package com.metal666.lab1.data.animals

class Dog(name: String, sex: Sex) : AnimalBase(name, sex), IHasVoice {

	override fun loudVoice() = say("YOOO DAWWGGG, WASSUP")

	override fun quietVoice() = say("pssst, i got sum gud stuf here, if ya know what i mean...")

	override fun say(phrase: String) = "*barks* $phrase"

}