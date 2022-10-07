package com.metal666.lab1.data.animals

class Cat(name: String, sex: Sex) : AnimalBase(name, sex), IHasVoice {

	override fun loudVoice() = say("HEY MAN, GIMMME SUMM FISHHHH")

	override fun quietVoice() = say("bewwy rubs, pweeaasee")

	override fun say(phrase: String) = "*meows* $phrase"
}