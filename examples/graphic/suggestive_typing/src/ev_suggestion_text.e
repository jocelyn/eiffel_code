note
	description: "Descendant of EV_TEXT equipped with suggestive typing."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date: 2012-03-15 21:32:02 +0100 (jeu., 15 mars 2012) $"
	revision: "$Revision: 88411 $"

class
	EV_SUGGESTION_TEXT

inherit
	EV_TEXT
		redefine
			create_interface_objects,
			initialize
		end

	EV_ABSTRACT_SUGGESTION_FIELD
		redefine
			create_interface_objects,
			insert_suggestion,
			displayed_text
		end

create
	make,
	make_with_settings

feature{NONE} -- Initialization

	make (a_provider: like suggestion_provider)
			-- Initialize current using suggestion provider `a_provider'.
			-- If `a_provider.is_concurrent', then Current might create a new thread
			-- of control to perform the query.
		do
			suggestion_provider := a_provider
			default_create
		ensure
			suggestion_provider_set: suggestion_provider = a_provider
		end

	make_with_settings (a_provider: like suggestion_provider; a_settings: like settings)
			-- Initialize current using suggestion provider `a_provider' and associated `a_settings' settings.
			-- If `a_provider.is_concurrent', then Current might create a new thread
			-- of control to perform the query.
		do
			suggestion_provider := a_provider
			internal_settings := a_settings
			default_create
		ensure
			suggestion_provider_set: suggestion_provider = a_provider
			settings_set: internal_settings = a_settings
		end

	create_interface_objects
			-- <Precursor>
		do
			Precursor {EV_ABSTRACT_SUGGESTION_FIELD}
			Precursor {EV_TEXT}
		end

	initialize
			-- Initialize current.
		do
			Precursor
			initialize_suggestion_field
		end

	expression_text: STRING_32
		local
			i: INTEGER
			l_text: like text
		do
			l_text := text
			i := word_begin_position (l_text, caret_position)
			if i > 0 then
				Result := l_text.substring (i, caret_position - 1)
			else
				Result := ""
			end
		end

	displayed_text: STRING_32
		do
			Result := expression_text
		end

	word_begin_position (a_text: like text; a_caret_position: INTEGER): INTEGER
		local
			l_text: STRING_32
			i: INTEGER
		do
			l_text := a_text
				-- Translate the `a_caret_position' as an index in the string
			i := a_caret_position - 1
			if not l_text.is_empty and l_text.valid_index (i) then
					-- First we skipp all spaces at the left of the `caret_position'.
				if l_text.item (i).is_space then
					Result := i + 1
				else
					from until i = 0 or else not l_text.item (i).is_space loop
						i := i - 1
					end

						-- Then we remove all the non-spaces characters until we hit a space.
					from until i = 0 or else l_text.item (i).is_space loop
						i := i - 1
					end

						-- Remove the text that we will not keep.
					if l_text.valid_index (i) and then l_text.item (i).is_space then
						Result := i + 1
					else
						Result := 1
					end
				end
			else
				Result := 0
			end
		end

feature {NONE} -- Implementation

	move_caret_to (a_pos: INTEGER)
			-- <Precursor>
		do
			set_caret_position (a_pos.max (1).min (text_length + 1))
		end

	move_caret_to_end
			-- <Precursor>
		do
			set_caret_position (text_length + 1)
		end

	delete_character_before
			-- <Precursor>
		do
			if text_length > 0 and caret_position > 1 then
				select_region (caret_position - 1, caret_position - 1)
				delete_selection
			end
		end

	delete_character_after
			-- <Precursor>
		do
			if text_length > 0 and caret_position <= text_length then
				select_region (caret_position, caret_position)
				delete_selection
			end
		end

	delete_word_before
			-- <Precursor>
		local
			l_text: STRING_32
			i: INTEGER
			l_has_trailing_space: BOOLEAN
		do
			l_text := text
				-- Translate the `caret_position' as an index in the string
				-- for deleting text at the left of `caret_position'.
			i := caret_position - 1
			if not l_text.is_empty and l_text.valid_index (i) then
					-- If the character at the right of the `caret_position' is a space, we
					-- remove all spaces after removing all non-space characters.
				l_has_trailing_space := l_text.valid_index (i + 1) and then l_text.item (i + 1).is_space

					-- First we remove all spaces at the left of the `caret_position'.
				from until i = 0 or else not l_text.item (i).is_space loop
					i := i - 1
				end

					-- Then we remove all the non-spaces characters until we hit a space.
				from until i = 0 or else l_text.item (i).is_space loop
					i := i - 1
				end

				if l_has_trailing_space then
						-- We need to remove all the leading spaces of the word we just removed
						-- because initially the character at the right of the `caret_position'
						-- was a space.
					from until i = 0 or else not l_text.item (i).is_space loop
						i := i - 1
					end
				end
					-- Remove the text that we will not keep.
				set_selection (i + 1, caret_position)
				delete_selection
			end
		end

	delete_word_after
			-- <Precursor>
		local
			l_text: STRING_32
			i, nb: INTEGER
			l_has_leading_space, l_remove_spaces_only: BOOLEAN
		do
			l_text := text
				-- Translate the `caret_position' as an index in the string
				-- for deleting text at the right of `caret_position'.
			i := caret_position
			nb := text_length
  			if not l_text.is_empty and l_text.valid_index (i) then
					-- If the character at the left of the `caret_position' is a space, we
					-- remove all spaces after removing all non-space characters.
				l_has_leading_space := not l_text.valid_index (i - 1) or else l_text.item (i - 1).is_space

					-- If the character at the right of the `caret_position'
					-- is a space and the character at the left (if any) if also a space
					-- then we only remove spaces, nothing else.
				l_remove_spaces_only := l_text.item (i).is_space and then l_has_leading_space

					-- First we remove all spaces at the right of the `caret_position'.
				from until i > nb or else not l_text.item (i).is_space loop
					i := i + 1
				end

				if not l_remove_spaces_only then
						-- Then we remove all the non-spaces characters until we hit a space.					
					from until i > nb or else l_text.item (i).is_space loop
						i := i + 1
					end

					if l_has_leading_space then
							-- We need to remove all the trailing spaces of the word we just removed
							-- because initially the character at the left of the `caret_position'
							-- was a space.
						from until i > nb or else not l_text.item (i).is_space loop
							i := i + 1
						end
					end
				end
					-- Remove the text that we will not keep.
				set_selection (caret_position, i)
				delete_selection
			end
		end

	insert_suggestion (a_text: STRING_32; a_selected_item: like last_suggestion)
			-- Insert `a_text' in Current if valid, move caret to the end and update last_suggestion.
			-- (from EV_ABSTRACT_SUGGESTION_FIELD)
			-- (export status {EV_SUGGESTION_WINDOW})
		local
			i: INTEGER
			l_text: like text
			l_old_caret_position: INTEGER
		do
			last_suggestion := a_selected_item
			if not a_text.is_empty and not a_text.has_code (('%R').natural_32_code) then
				l_old_caret_position := caret_position
--				i := l_old_caret_position
				i := word_begin_position (text, l_old_caret_position)
				if i > 0 then
					if i < l_old_caret_position then
						set_selection (i, l_old_caret_position)
						delete_selection
						set_caret_position (text_length.min (i))
					end
					i := caret_position
					insert_text (a_text)
					set_caret_position (i + a_text.count)
				else
					set_text (a_text)
					move_caret_to_end
				end
			end
			refresh
		end

	insert_string (a_str: STRING_32)
			-- Insert `a_str' at cursor position.
		do
			insert_text (a_str)
			set_caret_position (caret_position + a_str.count)
		end

	insert_character (a_char: CHARACTER_32)
			-- Insert `a_char' at cursor position.
		do
			insert_text (create {STRING_32}.make_filled (a_char, 1))
			set_caret_position (caret_position + 1)
		end

--	insert_string (a_str: STRING_32)
--			-- Insert `a_str' at cursor position.
--		local
--			i: INTEGER
--			l_text: like text
--		do
--			l_text := text
--			i := word_begin_position (l_text, caret_position)
--			if i > 0 then
--				l_text.replace_substring (a_str, i + 1, caret_position)
--				insert_text (l_text)
--				set_caret_position (i + 1 + a_str.count)
--			else
--				insert_text (a_str)
--				set_caret_position (caret_position + a_str.count)
--			end
--		end

--	insert_character (a_char: CHARACTER_32)
--			-- Insert `a_char' at cursor position.
--		local
--			i: INTEGER
--			l_text: like text
--		do
--			insert_string (a_char.as_string_32)
----			l_text := text
----			i := word_begin_position (l_text, caret_position)
----			if i > 0 then
----				l_text.insert_character (a_char, i: INTEGER_32)
----				l_text.replace_substring (a_str, i + 1, caret_position)
----				insert_text (l_text)
----				set_caret_position (i + 1 + a_str.count)
----			else
----				insert_text (create {STRING_32}.make_filled (a_char, 1))
----				set_caret_position (caret_position + 1)
----			end
--		end

	block_focus_in_actions
			-- Block focus in actions.
		do
			focus_in_actions.block
		end

	resume_focus_in_actions
			-- Resume focus in actions.
		do
			focus_in_actions.resume
		end

	block_focus_out_actions
			-- Block focus out actions.
		do
			focus_out_actions.block
		end

	resume_focus_out_actions
			-- Resume focus out actions.
		do
			focus_out_actions.resume
		end

note
	copyright: "Copyright (c) 1984-2012, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"

end
