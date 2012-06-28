note
	description: "Objects that ..."
	author: ""
	date: "$Date: 2006-03-10 16:50:31 +0100 (Fri, 10 Mar 2006) $"
	revision: "$Revision: 17 $"

class
	LARGE_RAW_FILE

inherit
	LARGE_RAW_FILE_I
		redefine
			move, go, count, position,
			off, back, forth, readable, file_readable,
			next_line_starting_with, move_to_next_line,
			read_character, read_line, read_stream, start
		end

create
	make


feature -- change

	file_readable: BOOLEAN
			-- Is there a current item that may be read?
		do
			Result := (mode >= Read_write_file or mode = Read_file)
						and readable
		end

	readable: BOOLEAN
		do
			Result := not off
		end

	back
		do
			move_64 (-1)
		end

	forth
		do
			move_64 (+1)
		end

	move (nb: INTEGER_64)
		do
			move_64 (nb)
		end

	go (pos: INTEGER_64)
		do
			go_64 (pos)
		end

	start
		do
			go_64 (0)
		end

feature -- query

	off: BOOLEAN
		do
			Result := (count = 0) or else is_closed or else end_of_file
		end

	count: INTEGER_64
		do
			Result := count_64
		end

	position: INTEGER_64
		do
			Result := position_64
		end

feature -- Input

	read_character
		do
			last_character := file_gc (file_pointer)
		end

	read_line
		local
			str_cap: INTEGER
			read: INTEGER	-- Amount of bytes already read
			str_area: ANY
			done: BOOLEAN
			l: like last_string
		do
			l := last_string
			from
				str_area := l.area
				str_cap := l.capacity
			until
				done
			loop
				read := read + file_gs (file_pointer, $str_area, str_cap, read)
				if read > str_cap then
						-- End of line not reached yet
						--|The string must be consistently set before
						--|resizing.
					l.set_count (str_cap)
					if str_cap < 2048 then
						l.grow (str_cap + 1024)
					else
							-- Increase capacity by `Growth_percentage' as
							-- defined in RESIZABLE.
						l.automatic_grow
					end
					str_cap := l.capacity
					read := read - 1		-- True amount of byte read
					str_area := l.area
				else
					l.set_count (read)
					done := True
				end
			end
		end

	read_stream (nb_char: INTEGER)
		local
			new_count: INTEGER
			str_area: ANY
			l: like last_string
		do
			l := last_string
			l.grow (nb_char)
			str_area := l.area
			new_count := file_gss (file_pointer, $str_area, nb_char)
			l.set_count (new_count)
		end

	next_line_starting_with (ac: STRING): STRING
		local
			c: CHARACTER
		do
			read_character
			c := last_character
			move (-1)
			if ac.has (c) then
				read_line
				Result := last_string
			else
				move_to_next_line
			end
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

feature -- useful for  C 64 API

feature {NONE} -- C 64 API

	count_64: INTEGER_64
			-- Size in bytes (0 if no associated physical file)
		do
			if exists then
				if not is_open_write then
					check False end
				else
					file_size_64 (file_pointer, $Result)
				end
			end
		end

	file_size_64 (afile: POINTER; res: TYPED_POINTER [INTEGER_64])
			-- Size of `file'
		external
			"C inline use %"eif_eiffel.h%",<stdio.h>,<sys/stat.h>,<sys/types.h>,<errno.h>"
		alias
			"[
		{
			struct __stat64 buf;
			errno = 0;
			if (0 != fflush((FILE *)$afile)) {
				esys();
			}
			if (_fstati64(_fileno((FILE *)$afile), &buf) == -1) {
				esys();
			}
			*$res = (EIF_INTEGER_64)buf.st_size;
		}
			]"
		end

	go_64 (abs_position: INTEGER_64)
			-- Go to the absolute `position'.
			-- (New position may be beyond physical length.)
		require
			file_opened: not is_closed
			non_negative_argument: abs_position >= 0
		do
			file_go_64 (file_pointer, abs_position)
		end

	move_64 (nb: INTEGER_64)
		do
			file_move_64 (file_pointer, nb)
		end

	position_64: INTEGER_64
			-- Current cursor position.
		do
			if not is_closed then
				Result := file_tell_64 (file_pointer)
			end
		end

	file_go_64 (afile: POINTER; abs_position: INTEGER_64)
			-- Go to absolute `position', originated from start.
		external
			"C inline use %"eif_eiffel.h%",<stdio.h>,<sys/stat.h>,<sys/types.h>,<errno.h>"
		alias
			"[
			errno = 0;
			if (0 != _fseeki64((FILE *)$afile, $abs_position, 0)) { /*FS_START)) {*/
				esys();
			}
			clearerr($afile);
			]"
		end

	file_move_64 (afile: POINTER; offset: INTEGER_64)
			-- Go to absolute `position', originated from start.
		external
			"C inline use %"eif_eiffel.h%",<stdio.h>,<sys/stat.h>,<sys/types.h>,<errno.h>"
		alias
			"[
			errno = 0;
			if (0 != _fseeki64((FILE *)$afile, $offset, 1)) { /*FS_CUR)) {*/
				esys();
			}
			clearerr($afile);
			]"
		end

	file_tell_64 (afile: POINTER): INTEGER_64
			-- Current cursor position in file.
		external
			"C inline use <stdio.h>,<sys/stat.h>,<sys/types.h>,<errno.h>"
		alias
			"_ftelli64((FILE*)$afile)"
		end

end
