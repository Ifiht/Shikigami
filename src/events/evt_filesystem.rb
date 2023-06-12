require "yaml"

watch_maildir_thread = Thread.start do
  loop do
    count = %x(ls $HOME/Maildir/new | wc -l).chomp.to_i
    if count > 0
      update_file = %x(ls $HOME/Maildir/new|head -1)
      update_string = %x(cat $HOME/Maildir/new/`ls $HOME/Maildir/new|head -1`)
      puts "New mail(#{Time.now}): #{update_file}"
      %x(mv $HOME/Maildir/new/`ls $HOME/Maildir/new|head -1` $HOME/Maildir/cur/`ls $HOME/Maildir/new|head -1`)
    end#if
    sleep 5
  end#loop
end#thread
