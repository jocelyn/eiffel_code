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
			tf_fruits: EV_MULTIPLE_SUGGESTION_TEXT_FIELD
			cwd: READABLE_STRING_GENERAL

			text: EV_SUGGESTION_TEXT
		do
			create vb
			extend (vb)

			-- Normal text field
			create lab.make_with_text ("Normal text field")
			vb.extend (lab)
			vb.disable_item_expand (lab)
			vb.extend (create {EV_TEXT_FIELD}.make_with_text ("this is a normal text field"))
			vb.disable_item_expand (vb.last)

			-- Fruit
			create lab.make_with_text ("Select a fruit")
			vb.extend (lab)
			vb.disable_item_expand (lab)

			create l_settings.make
			l_settings.set_matcher (create {CASE_INSENSITIVE_SUBSTRING_SUGGESTION_MATCHER})
			create tf.make_with_settings (create {ITERABLE_SUGGESTION_PROVIDER [READABLE_STRING_8]}.make (available_fruits), l_settings)
			tf.set_tooltip (lab.text)
			tf_fruit := tf
			vb.extend (tf)
			vb.disable_item_expand (tf)

			-- Fruits
			create lab.make_with_text ("Select several fruits")
			vb.extend (lab)
			vb.disable_item_expand (lab)

			create l_settings.make
			l_settings.set_matcher (create {CASE_INSENSITIVE_SUBSTRING_SUGGESTION_MATCHER})
			l_settings.set_searched_text_agent (agent (s: STRING_32): STRING_32
					do
						Result := s.string
						Result.left_adjust
					end)
			create tf_fruits.make_with_settings (create {ITERABLE_SUGGESTION_PROVIDER [READABLE_STRING_8]}.make (available_fruits), l_settings)

			tf_fruits.set_is_text_limit_agent (agent (c: CHARACTER_32): BOOLEAN
					do
						Result := c = ','
					end)
			tf_fruits.set_tooltip (lab.text)
			vb.extend (tf_fruits)
			vb.disable_item_expand (tf_fruits)


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
			create text.make_with_settings (create {ITERABLE_SUGGESTION_PROVIDER [READABLE_STRING_8]}.make (available_fruits), l_settings)
			vb.extend (text)
			text.set_text ("Soon .. inline suggesting typing demo")

		end

feature -- Access

	available_fruits: ARRAY [READABLE_STRING_8]
		do
			Result := <<"Orange", "Pineapple", "Apple", "Banana", "Peach", "Pear", "Kiwi">>
		end

feature -- Change

feature {NONE} -- Implementation

invariant
--	invariant_clause: True

end
