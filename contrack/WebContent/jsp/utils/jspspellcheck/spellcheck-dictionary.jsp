<%/*

    spellcheck-dictionary.jsp - This file is responsible for setting the
     dictionary variable that spellcheck-results uses to perform the spell
     check. Feel free to modify this to use a different dictionary if you
     have the need.
 
    Copyright (C) 2005 Balanced Insight, Inc.

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/%>

<%@ page import="java.io.InputStreamReader,com.swabunga.spell.engine.SpellDictionary"%>

<%

SpellDictionary dictionary = (SpellDictionary)application.getAttribute( "dictionary" );

synchronized( this )
{
    if( dictionary == null )
    {
        ClassLoader myLoader = this.getClass().getClassLoader();
        
        // Note: we could use a different dictionary and phonet file...
        //  It also, might be nice to create a map of locale's to dictionaries...
        dictionary = new SpellDictionaryHashMap(new InputStreamReader( myLoader.getResourceAsStream("spellcheck-english.0" ) ) );
        
        // We could use the phonet.en file - however I think that the DoubleMetaphone is doing a better job (mi->my, nam->name).
        //    ,new InputStreamReader( myLoader.getResourceAsStream( "phonet.en" ) )
    
        application.setAttribute( "dictionary", dictionary );
    }
}

%>