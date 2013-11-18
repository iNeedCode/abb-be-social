﻿<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SignIn.aspx.cs" Inherits="SignIn" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>ABBConnect</title>
    <!-- Bootstrap -->
    <link href="<%=ResolveUrl("~/content/css/bootstrap.css")%>" rel="stylesheet" type="text/css" />
    <link href="<%=ResolveUrl("~/content/css/site.css")%>" rel="stylesheet" type="text/css" />
    <script src="<%=ResolveUrl("~/content/js/jquery-2.0.3.min.js")%>" type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/content/js/bootstrap.js")%>" type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/content/js/ui.js")%>" type="text/javascript"></script>

    <!-- Plugins -->
    <script src="<%=ResolveUrl("~/content/js/bootstrap.js")%>" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container sign-in-form">
            <div class="row">
                <div class="col-md-4 col-md-offset-4">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title">Sign In</h3>
                        </div>
                        <div class="panel-body">
                            <form accept-charset="UTF-8" role="form">
                                <fieldset>
                                    <img src="content/img/abb_logo.png" class="sign-in-logo">
                                    <hr>
                                    <div class="input-group">
                                        <span class="input-group-addon"><span class="glyphicon glyphicon-user"></span></span>
                                        <input type="text" class="form-control" placeholder="Username" required="" autofocus="">
                                    </div>
                                    <div class="input-group">
                                        <span class="input-group-addon"><span class="glyphicon glyphicon-lock"></span></span>
                                        <input type="password" class="form-control" placeholder="Password" required="">
                                    </div>
                                    <div class="checkbox">
                                        <label>
                                            <input name="remember" type="checkbox" value="Remember Me">
                                            Remember Me
                                        </label>
                                    </div>
                                    <input class="btn btn-lg btn-danger btn-block" type="submit" value="Login">
                                </fieldset>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
