
note
	description : "Objects that ..."
	author      : "$Author: jfiat $"
	date        : "$Date: 2006-03-17 17:42:53 +0100 (Fri, 17 Mar 2006) $"
	revision    : "$Revision: 30 $"

class
	LARGE_RAW_FILE_I

inherit
	MODIFIED_RAW_FILE_I
--		export
--			{NONE} all;
--			{ANY} create_read_write,
--				is_closed,is_open_write, is_open_read, is_open_append,
--				open_read_write,
--				close,
--				open_read,
--				end_of_file,
--				last_string,
--				put_string,
--				start,
--				read_to_managed_pointer,
--				put_managed_pointer,
--				before, after, exists,
--				ex
		redefine
			old_move,
			old_go,
			old_count,
			old_position,
			old_off,
			old_back,
			old_forth,
			old_readable,
			old_file_readable,
			old_read_character,
			old_read_line,
			old_read_stream,

			make, close
		end

create
	make

feature {NONE} -- Initialization

	make (fn: STRING)
		do
			debug
				print (generator + ".make ("+fn+")%N")
			end
			Precursor (fn)
		end

feature -- Old

	old_read_line
		do
			Precursor
		end

	old_read_stream (nb_char: INTEGER)
		do
			Precursor (nb_char)
		end

	old_read_character
		do
			Precursor
		end

	old_file_readable: BOOLEAN
		do
			Result := Precursor
		end

	old_back
		do
			Precursor
		end

	old_forth
		do
			Precursor
		end

	old_off: BOOLEAN
			-- Is there no item?
		do
			Result := Precursor
		end

	old_move (nb: INTEGER)
		do
			Precursor (nb)
		end

	old_go (pos: INTEGER)
		do
			Precursor (pos)
		end

	old_count: INTEGER
		do
			Result := Precursor
		end

	old_position: INTEGER
		do
			Result := Precursor
		end

	old_readable: BOOLEAN
		do
			Result := Precursor
		end

feature -- Access

	close
		do
			debug
				print (generator + ".close%N")
			end
			Precursor
		end


	read_line
		do
			old_read_line
		end

	read_stream (nb_char: INTEGER)
		do
			old_read_stream (nb_char)
		end

	read_character
		do
			old_read_character
		end

	file_readable: BOOLEAN
			-- Is there a current item that may be read?
		do
			Result := old_file_readable
		end

	readable: BOOLEAN
		do
			Result := old_readable
		end

	back
		do
			old_back
		end

	forth
		do
			old_forth
		end

	off: BOOLEAN
		do
			Result := old_off
		end

	move (nb: INTEGER_64)
		do
			old_move (nb.to_integer)
		end

	go (pos: INTEGER_64)
		do
			old_go (pos.to_integer)
		end

feature -- query

	count: INTEGER_64
		do
			Result := old_count
		end

	position: INTEGER_64
		do
			Result := old_position
		end

feature -- extra

	next_line_starting_with (ac: STRING): detachable STRING
		local
			c: CHARACTER
--			s: STRING
		do
			read_line
			if last_string.count > 0 then
				c := last_string.item (1)
				if ac.has (c) then
					Result := last_string
				else
					Result := Void
				end
			end
--			read_character
--			c := last_character
--			move (-1)
--			if ac.has (c) then
--				read_line
--				Result := last_string
--			else
--				move_to_next_line
--			end
		end

	move_to_next_line
		do
			debug
				print ("move_to_next_line: start "+ position.out +"%N")
			end
			from
				read_character
			until
				last_character = '%N' or end_of_file
			loop
				read_character
			end
			debug
				print ("move_to_next_line: end %N")
			end
		end

end

