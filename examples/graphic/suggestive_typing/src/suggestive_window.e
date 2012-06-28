note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	SUGGESTIVE_WINDOW

inherit
	EV_TITLED_WINDOW

create
	make

feature {NONE} -- Initialization

	make
		do
			make_with_title ("Suggestion ...")
			build_interface
			set_size (400, 400)
		end

	build_interface
		local
			vb: EV_VERTICAL_BOX
			tf: EV_SUGGESTION_TEXT_FIELD
			l_settings: EV_SUGGESTION_SETTINGS
			lab: EV_LABEL
			tf_folder, tf_fruit: EV_SUGGESTION_TEXT_FIELD
			cwd: READABLE_STRING_GENERAL

			text: EV_SUGGESTION_TEXT
		do
			create vb
			extend (vb)

			-- Fruits
			create lab.make_with_text ("Select a fruit")
			vb.extend (lab)
			vb.disable_item_expand (lab)

			create l_settings.make
			l_settings.set_matcher (create {CASE_INSENSITIVE_SUBSTRING_SUGGESTION_MATCHER})
			create tf.make_with_settings (create {ITERABLE_SUGGESTION_PROVIDER [STRING_8]}.make (<<"Orange", "Apple", "Banana", "Peach", "Pear", "Kiwi">>), l_settings)
			tf.set_tooltip (lab.text)
			tf_fruit := tf
			vb.extend (tf)
			vb.disable_item_expand (tf)

			-- Browse
			cwd := (create {EXECUTION_ENVIRONMENT}).current_working_directory
			create lab.make_with_text ({STRING_32} "Select a folder under " + cwd.as_string_32)
			vb.extend (lab)
			vb.disable_item_expand (lab)

			create l_settings.make
			l_settings.set_matcher (create {CASE_INSENSITIVE_STRING_STARTS_WITH_SUGGESTION_MATCHER})
			create tf.make_with_settings (create {FILE_SUGGESTION_PROVIDER}.make (cwd), l_settings)
			tf.set_tooltip (lab.text)
			tf_folder := tf
			vb.extend (tf)
			vb.disable_item_expand (tf)

			-- Inside an EV_TEXT ... ?

			create l_settings.make
			l_settings.set_matcher (create {CASE_INSENSITIVE_SUBSTRING_SUGGESTION_MATCHER})
			l_settings.set_suggestion_activator_characters (Void)
--			l_settings.*set
			create text.make_with_settings (create {ITERABLE_SUGGESTION_PROVIDER [STRING_8]}.make (<<"Orange", "Apple", "Banana", "Peach", "Pear", "Kiwi">>), l_settings)
			vb.extend (text)
			text.set_text ("Soon .. inline suggesting typing demo")
		end

feature -- Status

feature -- Change

feature {NONE} -- Implementation

invariant
--	invariant_clause: True

end
