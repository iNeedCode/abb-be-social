﻿<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="ProfilePage.aspx.cs" Inherits="_UserPage" %>

<%@ Register Src="controls/ProfileFeedPage.ascx" TagName="ProfileFeedPage" TagPrefix="abbConnect" %>
<%@ Register Src="controls/FeedComments.ascx" TagName="FeedComments" TagPrefix="abbConnect" %>
<%@ Register Src="controls/RealTimeSensorFeedPage.ascx" TagName="RealTimeSensorFeedPage" TagPrefix="abbConnect" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="row">        
        <div class="col-md-6">
            <div class="feed-header">
                <div class="form-inline">
                    <div class="form-group">                
                        <h3><span class="glyphicon glyphicon-link"></span>User feeds</h3>
                    </div>
                    <div class="form-group button-group">
                        <div class="btn-group">
                            <button id="human-feed-filter-selector-left" type="button" class="btn btn-info">Feed Selection</button>
                            <button id="human-feed-filter-selector-right" type="button" class="btn btn-info dropdown-toggle" data-toggle="dropdown">
                                <span class="caret"></span>
                                <span class="sr-only">Toggle Dropdown</span>
                            </button>
                            <ul class="dropdown-menu" role="menu">
                                <li><a href="#">Work post </a></li>
                                <li><a href="#">Sticky note</a></li>
                                <li><a href="#">Vacation post</a></li>
                                <li class="divider"></li>
                                <li><a href="#" data-toggle="modal" data-target="#modalHumanFeedsAddDateFilter">Date <span id="humanFeedsDateFilterIsActive" class="label label-success dont-show">ACTIVE</span></a>
                                </li>
                            </ul>
                        </div>
                        <div class="btn-group">
                            <button type="button" class="btn btn-primary">Publish</button>
                            <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
                                <span class="caret"></span>
                                <span class="sr-only">Toggle Dropdown</span>
                            </button>
                            <ul class="dropdown-menu" role="menu">
                                <li><a href="#" data-toggle="modal" data-target="#modalNote">Note</a></li>
                                <li><a href="#" data-toggle="modal" data-target="#modalPicture">Picture</a></li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
            <div id="feedsContainer">
                <abbConnect:ProfileFeedPage ID="ProfileFeedPage" runat="server" />
            </div>
            <div id="loading_throbber_human_feeds" class="loading-throbber" data-container="feedsContainer"></div>
        </div>
        <div class="col-md-6">
            <div class="feed-header">
                <div class="form-inline">
                    <div class="form-group">                
                        <h3><span class="glyphicon glyphicon-link"></span>Profile info</h3>
                    </div>
                </div>
            </div> 
            <div id='feed-container-one'>
            <div class="feed-inner-container feed-inner-container-default">
                <div class="feed-information">
                    <img class="profile-avatar" alt="" src="content/img/avatar-abb.png">
                </div>
                <div class="profile-view feed-message-default">
                    <a href="#" class="feed-name feed-name-default profile-page-user">
                        <asp:Literal runat="server" ID="UserName"></asp:Literal>
                    </a>
                    <span class="view-body">                        
                        <a href class="user-info feed-name-default">Location:</a>
                        <asp:Literal runat="server" ID="UserLocation"></asp:Literal><br/>
                        <a href class="user-info feed-name-default">Email:</a>
                        <asp:Literal runat="server" ID="UserEmail"></asp:Literal><br/>
                        <a href class="user-info feed-name-default">Phone number:</a>
                        <asp:Literal runat="server" ID="UserPhoneNumber"></asp:Literal><br/>
                    </span>
                </div>
            </div>
        </div>
    </div>

   <!-- Modals -->
    <div id="modals">
        <div class="modal fade" id="modalHumanFeedsAddDateFilter">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true"></button>
                        <h4 class="modal-title">Date Filter</h4>
                    </div>
                    <div class="modal-body np">
                        <table class="table table-filter">
                            <tbody>
                                <tr class="no-tb">
                                    <td><input id="chbHumanFeedsFilterStartDate" type="checkbox" class="bs" data-datepicker="datepickerStart"/></td>
                                    <td class="filterDateText">Starting Date</td>
                                    <td>
                                        <div id="datepickerStart">
                                            <div class="input-group date">
                                                <input type="text" class="form-control">
                                                <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                                 <tr class="no-bb">
                                    <td><input id="chbHumanFeedsFilterEndDate" type="checkbox" class="bs" data-datepicker="datepickerEnd"/></td>
                                    <td class="filterDateText">Ending Date</td>
                                    <td>
                                         <div id="datepickerEnd">
                                            <div class="input-group date">
                                                <input type="text" class="form-control">
                                                <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary" onclick="SaveHumanFeedsFilterData(1)">Save changes</button>
                    </div>
                </div>
                <!-- /.modal-content -->
            </div>
            <!-- /.modal-dialog -->
        </div>
        <!-- /.modal -->
        <div class="modal fade" id="modalNote" tabindex="-1" role="dialog" aria-labelledby="modalNoteLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                        <h4 class="modal-title" id="myModalLabel">Add a new note</h4>
                    </div>
                    <div class="modal-body">
                        <h5>Please select the note type:</h5>
                        <!--SelectBox for post body-->
                        <select class="form-control" id="selectModalNoteMessage">
                        </select>
                        <hr>
                        <h5>Please insert new note text:</h5>
                        <!-- Textbox -->
                        <textarea id="textareaNote" class="input col-md-12" placeholder="Insert your note text here..." rows="5" ></textarea>
                        <br />
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary" data-dismiss="modal" onclick="AjaxPostNewFeed()">Post new note</button>
                    </div>
                </div>
                <!-- /.modal-content -->
            </div>
            <!-- /.modal-dialog -->
        </div>
        <!-- /.modal -->
        <div class="modal fade" id="modalPicture" tabindex="-1" role="dialog" aria-labelledby="modalPictureLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                        <h4 class="modal-title" id="H1">Add a new picture note</h4>
                    </div>
                    <div class="modal-body">
                        <!-- File upload-->
                        <input id="filePicture" type="file" style="display: none" />
                        <div class="input-append">
                            <input id="inputPicturePath" class="input-large" type="text" style="width: 85%;" />
                            <a class="btn" onclick="$('input[id=filePicture]').click();">Browse</a>
                        </div>

                        <script type="text/javascript">
                            $('input[id=filePicture]').change(function () {
                                $('#inputPicturePath').val($(this).val());
                            });
                        </script>

                        <br />
                        <h5>Please insert the description of the picture:</h5>

                        <!-- Textbox -->
                        <div class="input-group">
                            <span class="input-group-addon"></span>
                            <textarea class="input" placeholder="Insert your note text here..." style="width: 100%; resize: vertical"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal" onclick="ClearModal()">Close</button>
                        <button type="button" class="btn btn-primary" data-dismiss="modal" onclick="ClearModal()">Post new picture note</button>
                    </div>
                </div>
                <!-- /.modal-content -->
            </div>
            <!-- /.modal-dialog -->
        </div>
        <!-- /.modal -->       
    </div>
    <asp:HiddenField runat="server" ClientIDMode="Static" ID="humanFeedsFilterStartDateIsChecked" Value="false"/>
    <asp:HiddenField runat="server" ClientIDMode="Static" ID="humanFeedsFilterStartDateValue"/>
    <asp:HiddenField runat="server" ClientIDMode="Static" ID="humanFeedsFilterEndDateIsChecked" Value="false"/>
    <asp:HiddenField runat="server" ClientIDMode="Static" ID="humanFeedsFilterEndDateValue"/>
    
    <asp:HiddenField runat="server" ClientIDMode="Static" ID="realTimeSensorFeedsFilterStartDateIsChecked" Value="false"/>
    <asp:HiddenField runat="server" ClientIDMode="Static" ID="realTimeSensorFeedsFilterStartDateValue"/>
    <asp:HiddenField runat="server" ClientIDMode="Static" ID="realTimeSensorFeedsFilterEndDateIsChecked" Value="false"/>
    <asp:HiddenField runat="server" ClientIDMode="Static" ID="realTimeSensorFeedsFilterEndDateValue"/>
    <script>
        // Instances of sensor gauges, should be in ui.js !
        //var g1 = new JustGage({
        //    id: "gauge-996",
        //    value: getRandomInt(800, 980),
        //    min: 0,
        //    max: 1000,
        //    title: "Water flow [m3/h]",
        //    gaugeWidthScale: 0.5
        //});
        //var g2 = new JustGage({
        //    id: "gauge-995",
        //    value: getRandomInt(110, 280),
        //    min: 0,
        //    max: 400,
        //    title: "Wind speed [km/h]"
        //});

        //listener for clearing the modals
        //ClearModalBodyListener();

        //  PopulateSelectBoxPostType();
    </script>
</asp:Content>