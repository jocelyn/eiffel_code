note
	description: "Descendant of EV_TEXT_FIELD equipped with suggestive typing."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date: 2012-06-28 17:39:34 +0200 (jeu., 28 juin 2012) $"
	revision: "$Revision: 89018 $"

class
	EV_MULTIPLE_SUGGESTION_TEXT_FIELD

inherit
	EV_SUGGESTION_TEXT_FIELD
		redefine
			displayed_text,
			set_displayed_text,
			move_caret_to_end
		end

create
	make,
	make_with_settings

feature -- Text limit

	is_text_limit_agent: detachable FUNCTION [ANY, TUPLE [CHARACTER_32], BOOLEAN]

	set_is_text_limit_agent (agt: like is_text_limit_agent)
		do
			is_text_limit_agent := agt
		end

	is_text_limit (c: CHARACTER_32): BOOLEAN
		do
			if attached is_text_limit_agent as agt then
				Result := agt.item ([c])
			else
				Result := c.is_space
			end
		end

feature -- Text operation

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
