package com.metal666.lab1.views.adapters

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.recyclerview.widget.RecyclerView
import com.metal666.lab1.R
import com.metal666.lab1.data.animals.AnimalBase
import com.metal666.lab1.data.animals.IHasVoice

class AnimalRecyclerAdapter(private val context: Context, private val animals: List<AnimalBase>) : RecyclerView.Adapter<AnimalRecyclerAdapter.AnimalRecyclerHolder>() {

	private val onVoice: (AnimalBase, (IHasVoice) -> String) -> Unit = { animal, voice ->

		val builder = AlertDialog.Builder(context)

		with(builder) {

			setTitle("${animal.javaClass.simpleName} ${animal.name} says:")

			setMessage(voice(animal as IHasVoice))

			setPositiveButton("OK", null)

			show()

		}

	}

	private val onLoudVoice: (AnimalBase) -> Unit = { animal -> onVoice(animal) { hasVoice -> hasVoice.loudVoice() } }

	private val onQuietVoice: (AnimalBase) -> Unit = { animal -> onVoice(animal) { hasVoice -> hasVoice.quietVoice() } }

	override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): AnimalRecyclerHolder =
		AnimalRecyclerHolder(LayoutInflater
			.from(parent.context)
			.inflate(R.layout.animal_recycler_item, parent, false))

	override fun onBindViewHolder(holder: AnimalRecyclerHolder, position: Int) {

		val animal = animals[position];

		holder.animalType.text = context.getString(R.string.animal_type, animal.javaClass.simpleName)
		holder.animalName.text = context.getString(R.string.animal_name, animal.name)
		holder.animalSex.text = context.getString(R.string.animal_sex, animal.sex.toString())

		if(animal is IHasVoice) {

			holder.animalVoiceLoud.setOnClickListener { onLoudVoice(animal) }
			holder.animalVoiceQuiet.setOnClickListener { onQuietVoice(animal) }

		} else {

			holder.animalVoiceLoud.visibility = View.GONE
			holder.animalVoiceQuiet.visibility = View.GONE

		}

	}

	override fun getItemCount(): Int = animals.size

	class AnimalRecyclerHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {

		val animalType: TextView = itemView.findViewById(R.id.animal_type)
		val animalName: TextView = itemView.findViewById(R.id.animal_name)
		val animalSex: TextView = itemView.findViewById(R.id.animal_sex)

		val animalVoiceLoud: Button = itemView.findViewById(R.id.animal_voice_loud)
		val animalVoiceQuiet: Button = itemView.findViewById(R.id.animal_voice_quiet)

	}

}