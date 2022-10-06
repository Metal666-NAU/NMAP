package com.metal666.lab1.data.animals

abstract class Animal(var name: String, val sex: Sex) {

	var age: Float = 0f

	protected abstract fun say(phrase: String): String

	enum class Sex {
		MALE,
		FEMALE,
		UNKNOWN
	}

}