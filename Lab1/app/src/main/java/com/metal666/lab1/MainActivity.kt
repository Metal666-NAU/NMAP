package com.metal666.lab1

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.metal666.lab1.data.animals.AnimalBase
import com.metal666.lab1.data.animals.Cat
import com.metal666.lab1.data.animals.Dog
import com.metal666.lab1.data.animals.Fish
import com.metal666.lab1.views.adapters.AnimalRecyclerAdapter
import kotlin.random.Random

class MainActivity : AppCompatActivity() {

	private val animals: MutableList<AnimalBase> = mutableListOf()

	override fun onCreate(savedInstanceState: Bundle?) {

		super.onCreate(savedInstanceState)

		setContentView(R.layout.activity_main)

		val animalRecycler: RecyclerView = findViewById(R.id.animal_recycler)

		animalRecycler.layoutManager = LinearLayoutManager(this)
		animalRecycler.addItemDecoration(
			DividerItemDecoration(
				this,
				LinearLayoutManager.VERTICAL
			)
		)

		for (i in 0..20) {

			when(Random.nextInt(0, 3)) {

				0 -> animals.add(Dog(resources.getStringArray(R.array.dog_names).random(), AnimalBase.Sex.values().random()))
				1 -> animals.add(Cat(resources.getStringArray(R.array.cat_names).random(), AnimalBase.Sex.values().random()))
				2 -> animals.add(Fish(resources.getStringArray(R.array.fish_names).random(), AnimalBase.Sex.values().random()))

			}

		}

		animalRecycler.adapter = AnimalRecyclerAdapter(this, animals)

	}

}