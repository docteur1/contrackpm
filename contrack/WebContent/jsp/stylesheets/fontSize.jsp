<%@ page language="java" contentType="text/css; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
input,body,td,select,button,textarea{font-size:<%= attr.getFontSize() %>pt;}