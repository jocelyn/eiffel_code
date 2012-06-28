note
	description: "Summary description for {FILE_SUGGESTION_PROVIDER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FILE_SUGGESTION_PROVIDER

inherit
	SUGGESTION_PROVIDER

create
	make

feature {NONE} -- Make

	make (dn: READABLE_STRING_GENERAL)
		do
			dirname := dn.as_string_8
		end

	dirname: READABLE_STRING_8

feature -- Access

	query_with_callback_and_cancellation (a_expression: READABLE_STRING_GENERAL; a_termination: detachable PROCEDURE [ANY, TUPLE];
				a_callback: PROCEDURE [ANY, TUPLE [SUGGESTION_ITEM]]; a_cancel_request: detachable PREDICATE [ANY, TUPLE])
			-- Given a query `a_expression', and for each result execute `a_callback' until all results have been
			-- obtained or if `a_cancel_request' returns True.
			-- When list is fully built, `a_termination' will be called regardless of the cancellation of the query.
		do
			if a_cancel_request /= Void then
				across data (a_expression) as l_data until a_cancel_request.item (Void) loop
					a_callback.call ([create {LABEL_SUGGESTION_ITEM}.make (l_data.item)])
				end
			else
				across data (a_expression) as l_data loop
					a_callback.call ([create {LABEL_SUGGESTION_ITEM}.make (l_data.item)])
				end
			end
			if a_termination /= Void then
				a_termination.call (Void)
			end
		end

	data (a_expression: READABLE_STRING_GENERAL): ITERABLE [STRING_8]
		local
			s8: READABLE_STRING_8
			d: DIRECTORY
			sep: CHARACTER
			p: INTEGER
			dn: DIRECTORY_NAME
		do
			s8 := a_expression.as_string_8
			sep := Operating_environment.Directory_separator
			p := s8.last_index_of (sep, s8.count)
			create {ARRAYED_LIST [STRING_8]} Result.make (0)
			if p > 0 then
				create dn.make_from_string (dirname)
				dn.extend (s8.substring (1, p-1))
			else
				create dn.make_from_string (dirname)
			end
			create d.make (dn.string)
			debug
				print (d.name + "%N")
			end
			if d.exists and d.is_readable then
				d.open_read
				Result := d.linear_representation
				d.close
				across
					Result as c
				loop
					create dn.make_from_string (d.name)
					dn.extend (c.item)
					debug
						print ("%T" + c.item + "%N")
					end
					c.item.wipe_out
					c.item.append (dn.string)
					c.item.remove_head (dirname.count + 1)
				end
			else
			end
		end

feature -- Status Report

	is_concurrent: BOOLEAN
			-- Can `Current' be executed in a different thread/processor?
		do
			Result := True
		end

	is_available: BOOLEAN
			-- Is current able to serve a new query?
		do
			Result := True
		end

end
