create or replace package utl_mail as

  mail_conn   utl_smtp.connection;

  procedure send ( p_subject   in varchar2, p_message   in varchar2);
  
  procedure config ( p_mailhost varchar2 , p_sender varchar2 , p_recipient varchar2 );
 
end utl_mail;
/


create or replace package body utl_mail 
as
  procedure setheader (name varchar2, header varchar2)
  is
  begin
           utl_smtp.write_data( mail_conn ,name ||':'|| header || utl_tcp.crlf);
  end setheader;

  procedure send ( p_subject   IN varchar2,
                   p_message   IN varchar2 )
  iS
  mail_info utl$mail_info%rowtype;
  begin
          select * into mail_info from utl$mail_info;

          mail_conn :=utl_smtp.open_connection( mail_info.mailhost );
          utl_smtp.helo(mail_conn, mail_info.mailhost);
          utl_smtp.mail(mail_conn, mail_info.sender);    -- sender
          utl_smtp.rcpt(mail_conn, mail_info.recipient); -- recipient
          utl_smtp.open_data(mail_conn);


          setheader('From',    mail_info.sender );
          SetHeader('To',      mail_info.recipient );
          SetHeader('Subject', p_subject);

          utl_smtp.write_data(mail_conn, utl_tcp.CRLF||p_message);
          utl_smtp.close_data(mail_conn);
          utl_smtp.quit(mail_conn);

        exception
          when utl_smtp.transient_error OR utl_smtp.permanent_error then
            utl_smtp.quit(mail_conn);
            raise_application_error(-20000, 'Failed tosend mail due to the following error: ' || sqlerrm);
          when others then
            dbms_output.put_line( to_char(sqlcode)||' - '||sqlerrm );

  end send;


  -- + ----------------------------------------------------------------------------------------------------------------
  -- | Procedure   : isValidEmail
  -- | Description : Checks email address and return 1 if it's valid otherwise 0.
  -- + ----------------------------------------------------------------------------------------------------------------
  function isValidEmail( p_email in varchar2 ) 
  return number 
  is
      v_EmailRegexp CONSTANT VARCHAR2(1000) := '^[a-z0-9!#$%&''*+/=?^_`{|}~-]+(\.[a-z0-9!#$%&''*+/=?^_`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+([A-Z]{2}|arpa|biz|com|info|intww|name|net|org|pro|aero|asia|cat|coop|edu|gov|jobs|mil|mobi|museum|pro|tel|travel|post)$';
  begin
      if regexp_like(p_email, v_Emailregexp ) then
          return 1;
      else
          return 0;
      end if;
  end isvalidemail;

  -- + ----------------------------------------------------------------------------------------------------------------
  -- | Procedure   : config
  -- | Description : Receive three parameters and setup the meta data to send email
  -- + ----------------------------------------------------------------------------------------------------------------
  procedure config ( p_mailhost varchar2 , p_sender varchar2 , p_recipient varchar2 )
  is
    invalid_email_address exception;
    pragma exception_init( invalid_email_address , -20002 );
  begin
    if isValidEmail(p_recipient) = 0 then
        raise_application_error( -20002, 'Email address, '||p_recipient||' is not valid.');
    end if;
  
    insert into utl$mail_info values ( p_mailhost, p_sender , p_recipient );

    commit;

  exception 
  when invalid_email_address then
      dbms_output.put_line (  to_char(sqlcode)||' - '||sqlerrm ||' : '|| 'Please provide right email address.' );
  when others then
      dbms_output.put_line ( to_char(sqlcode)||' - '||sqlerrm );
      
  end config;

end utl_mail;
/

