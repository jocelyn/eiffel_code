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
			initialize,
			set_default_key_processing_handler,
			remove_default_key_processing_handler
		end

	EV_ABSTRACT_SUGGESTION_FIELD
		redefine
			create_interface_objects
		end

create
	make,
	make_with_settings

feature{NONE} -- Initialization

feature {NONE} -- Initialization

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

feature -- Status setting

	set_default_key_processing_handler (a_handler: like default_key_processing_handler)
			-- Set `default_key_processing_handler' with `new_default_key_processing_handler'.
			-- Set `old_default_key_processing_handler' with `a_handler' if different from
			-- `new_default_key_processing_handler'.
		do
			if a_handler /= new_default_key_processing_handler then
				old_default_key_processing_handler := a_handler
			end
			if default_key_processing_handler /= new_default_key_processing_handler then
				Precursor (new_default_key_processing_handler)
			end
		ensure then
			handler_set: default_key_processing_handler = new_default_key_processing_handler
			a_handler_preserved: a_handler /= new_default_key_processing_handler implies old_default_key_processing_handler = a_handler
		end

	remove_default_key_processing_handler
			-- Ensure `old_default_key_processing_handler' is Void while preserving our own handler.
		do
			old_default_key_processing_handler := Void
		ensure then
			default_handler_preserved: default_key_processing_handler = new_default_key_processing_handler
		end

feature -- Text limit

--	is_text_limit_agent: detachable FUNCTION [ANY, TUPLE [CHARACTER_32], BOOLEAN]

--	set_is_text_limit_agent (agt: like is_text_limit_agent)
--		do
--			is_text_limit_agent := agt
--		end

	is_text_limit (c: CHARACTER_32): BOOLEAN
		do
--			if attached is_text_limit_agent as agt then
--				Result := agt.item ([c])
--			else
				Result := c.is_space
--			end
		end

feature -- Text access
--	word_begin_position (a_text: like text; a_caret_position: INTEGER): INTEGER
--		local
--			l_text: STRING_32
--			i: INTEGER
--		do
--			l_text := a_text
--				-- Translate the `a_caret_position' as an index in the string
--			i := a_caret_position - 1
--			if not l_text.is_empty and l_text.valid_index (i) then
--					-- First we skipp all spaces at the left of the `caret_position'.
--				if l_text.item (i).is_space then
--					Result := i + 1
--				else
--					from until i = 0 or else not l_text.item (i).is_space loop
--						i := i - 1
--					end

--						-- Then we remove all the non-spaces characters until we hit a space.
--					from until i = 0 or else l_text.item (i).is_space loop
--						i := i - 1
--					end

--						-- Remove the text that we will not keep.
--					if l_text.valid_index (i) and then l_text.item (i).is_space then
--						Result := i + 1
--					else
--						Result := 1
--					end
--				end
--			else
--				Result := 0
--			end
--		end


	displayed_text_range: TUPLE [left,right: INTEGER]
		local
			l_text: like text
			p: like caret_position
			p1,p2: INTEGER
			len: INTEGER
		do
			l_text := text
			if l_text.is_empty then
				p1 := 1
				p2 := 0
			else
				p := caret_position
				len := l_text.count
				p1 := p
				if p <= 1 then
					p1 := 1
				elseif is_text_limit (l_text [p1 - 1]) then
				else
					from
						p1 := p1 - 1
					until
						p1 < 2 or else is_text_limit (l_text [p1 - 1])
					loop
						p1 := p1 - 1
					end
				end

				p2 := p
				if p2 >= len then
					p2 := len
				elseif is_text_limit (l_text [p2]) then
					p2 := (p2 - 1).max (p1)
				else
					from
						p2 := p2 + 1
					until
						p2 > len or else is_text_limit (l_text[p2])
					loop
						p2 := p2 + 1
					end
					p2 := p2 - 1
				end
			end

			Result := [p1, p2]
		end

	displayed_text: STRING_32
			-- Text which is currently displayed.
		local
			tu: like displayed_text_range
		do
			tu := displayed_text_range
			Result := text.substring (tu.left, tu.right)
		end

feature -- Text change

	set_displayed_text (a_text: READABLE_STRING_GENERAL)
			-- Set `a_text' to `displayed_text'.
		local
			tu: like displayed_text_range
		do
			print ("[" + a_text.out + "]%N")
			tu := displayed_text_range
			set_selection (tu.left, tu.right + 1)
			delete_selection
			insert_text (a_text)
		end

	move_caret_to_end
			-- <Precursor>
		do
			set_caret_position (displayed_text_range.right + 1)
		end

feature {NONE} -- Implementation

	select_all_text
			-- <Precursor>
		do
			select_all
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
