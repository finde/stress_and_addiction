classdef stress_addiction_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Sad_and_AddictionUIFigure  matlab.ui.Figure
        Menu                       matlab.ui.container.Menu
        LoadMenu                   matlab.ui.container.Menu
        SaveMenu                   matlab.ui.container.Menu
        MainLayout                 matlab.ui.container.GridLayout
        TabGroup                   matlab.ui.container.TabGroup
        DataTab                    matlab.ui.container.Tab
        GridLayoutDataTab          matlab.ui.container.GridLayout
        DataTabChildren            matlab.ui.container.TabGroup
        ALLTab                     matlab.ui.container.Tab
        GridLayout4                matlab.ui.container.GridLayout
        UITable_ALL                matlab.ui.control.Table
        GridLayout9                matlab.ui.container.GridLayout
        AddTo_Group1               matlab.ui.control.Button
        AddTo_Group2               matlab.ui.control.Button
        DeselectButton             matlab.ui.control.Button
        SelectButton               matlab.ui.control.Button
        Group_1Tab                 matlab.ui.container.Tab
        GridLayout5                matlab.ui.container.GridLayout
        UITable_Group_1            matlab.ui.control.Table
        Group_2Tab                 matlab.ui.container.Tab
        GridLayout6                matlab.ui.container.GridLayout
        UITable_Group_2            matlab.ui.control.Table
        SettingsTab                matlab.ui.container.Tab
        GridLayout2                matlab.ui.container.GridLayout
        GeneratorPanel             matlab.ui.container.Panel
        GridLayout7                matlab.ui.container.GridLayout
        GenerateButton             matlab.ui.control.Button
        SplitdatabyDropDownLabel   matlab.ui.control.Label
        SplitdatabyDropDown        matlab.ui.control.DropDown
        atvalueSpinnerLabel        matlab.ui.control.Label
        atvalueSpinner             matlab.ui.control.Spinner
        StatusLabel                matlab.ui.control.Label
        GraphPanel                 matlab.ui.container.Panel
        GridLayout8                matlab.ui.container.GridLayout
        UIAxes                     matlab.ui.control.UIAxes
        UIAxes_2                   matlab.ui.control.UIAxes
        UIAxes_3                   matlab.ui.control.UIAxes
        UIAxes_4                   matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        State = 'initial' % Description
        SADParams
        
        tempSelection
    end
    
    methods (Access = private)
        
        function updateDisplayVisibility(app, state)
            if nargin > 1
                app.State = state;
            end
            
            switch app.State
                case 'initial'
                    app.TabGroup.Visible = false;
                    app.GraphPanel.Visible = false;
                    app.SaveMenu.Enable = false;
                case 'loaded'
                    app.TabGroup.Visible = true;
                    app.GraphPanel.Visible = true;
                case 'updated'
                    app.SaveMenu.Enable = true;
                otherwise
                    disp('unknown state')
            end
        end
        
        function updateTableDataDisplay(app)
            [genderInfo, ageInfo, alcoholInfo, auditInfo]=sad.Database.report(app.SADParams);
            
            pie(app.UIAxes,genderInfo)
            app.UIAxes.Title.String="Gender";
     
            histogram(app.UIAxes_2, ageInfo.data, ageInfo.category)
            app.UIAxes_2.Title.String="Age";
            
            histogram(app.UIAxes_3, alcoholInfo.data);
            app.UIAxes_3.Title.String='Standard Alcohol Unit (Last 28days)';
            app.UIAxes_3.XLabel.String=['unknown = ' num2str(alcoholInfo.unknown)];
            
            histogram(app.UIAxes_4, auditInfo)
            app.UIAxes_4.Title.String="AUDIT";
            app.UIAxes_4.XTick=(-1:25);
            
            % app.UIAxes_2.Children(end).ButtonDownFcn = createCallbackFcn(app, @lineSelected, true);
        end
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.updateDisplayVisibility('initial');
        end

        % Menu selected function: LoadMenu
        function LoadMenuSelected(app, event)
            selpath = uigetdir('.','Load Experiment Directory');
            
            if ~isempty(selpath)
                app.SADParams = sad.InitializeSADparams(selpath);
                pause(1);
                app.UITable_ALL.ColumnName = app.SADParams.data.Properties.VariableNames;
                app.UITable_ALL.Data = app.SADParams.data;
                
                set(app.UITable_ALL,'ColumnEditable', [true true false false false false false false false false false false false false false false false false false false false false false])                
                set(app.UITable_ALL,'ColumnSortable', [true true true  true  true  true  true  true  true  true  true  true  true  true  true  true  true  true  true  true  true  true  true])                
                pause(1);
                
                app.updateDisplayVisibility('loaded');
                
                pause(1);
                app.updateTableDataDisplay();
            end
        end

        % Menu selected function: SaveMenu
        function SaveMenuSelected(app, event)
            sad.Database.save_data(app.SADParams);
            app.updateDisplayVisibility('loaded');
        end

        % Display data changed function: UITable_ALL
        function UITable_ALLDisplayDataChanged(app, event)
            app.updateDisplayVisibility('updated')
            app.SADParams.data = app.UITable_ALL.DisplayData;          
            app.updateTableDataDisplay();
        end

        % Button pushed function: AddTo_Group1
        function AddTo_Group1ButtonPushed(app, event)
            app.UITable_ALL.Data(app.tempSelection,:).Group = 1.*ones(length(app.tempSelection),1);
            app.tempSelection = [];
            app.updateDisplayVisibility('updated')
            app.SADParams.data = app.UITable_ALL.DisplayData;
            app.updateTableDataDisplay();
        end

        % Button pushed function: AddTo_Group2
        function AddTo_Group2ButtonPushed(app, event)
            app.UITable_ALL.Data(app.tempSelection,:).Group = 2.*ones(length(app.tempSelection),1);
            app.tempSelection = [];
            app.updateDisplayVisibility('updated')
            app.SADParams.data = app.UITable_ALL.DisplayData;
            app.updateTableDataDisplay();
        end

        % Cell selection callback: UITable_ALL
        function UITable_ALLCellSelection(app, event)
            indices = event.Indices;
            app.tempSelection = unique(indices(:,1));
        end

        % Button pushed function: SelectButton
        function SelectButtonPushed(app, event)
            app.UITable_ALL.Data(app.tempSelection,:).Selected = true(length(app.tempSelection),1);
            app.tempSelection = [];
            app.updateDisplayVisibility('updated')
            app.SADParams.data = app.UITable_ALL.DisplayData; 
            app.updateTableDataDisplay();
        end

        % Button pushed function: DeselectButton
        function DeselectButtonPushed(app, event)
            app.UITable_ALL.Data(app.tempSelection,:).Selected = false(length(app.tempSelection),1);
            app.tempSelection = [];
            app.updateDisplayVisibility('updated')
            app.SADParams.data = app.UITable_ALL.DisplayData; 
            app.updateTableDataDisplay();
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Sad_and_AddictionUIFigure and hide until all components are created
            app.Sad_and_AddictionUIFigure = uifigure('Visible', 'off');
            app.Sad_and_AddictionUIFigure.Position = [100 100 1182 822];
            app.Sad_and_AddictionUIFigure.Name = 'Sad_and_Addiction';

            % Create Menu
            app.Menu = uimenu(app.Sad_and_AddictionUIFigure);
            app.Menu.Text = 'Menu';

            % Create LoadMenu
            app.LoadMenu = uimenu(app.Menu);
            app.LoadMenu.MenuSelectedFcn = createCallbackFcn(app, @LoadMenuSelected, true);
            app.LoadMenu.Text = 'Load';

            % Create SaveMenu
            app.SaveMenu = uimenu(app.Menu);
            app.SaveMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveMenuSelected, true);
            app.SaveMenu.Text = 'Save';

            % Create MainLayout
            app.MainLayout = uigridlayout(app.Sad_and_AddictionUIFigure);
            app.MainLayout.ColumnWidth = {'1x', '1x', '1x'};
            app.MainLayout.RowHeight = {'1x', '2x', 30};

            % Create TabGroup
            app.TabGroup = uitabgroup(app.MainLayout);
            app.TabGroup.Layout.Row = 2;
            app.TabGroup.Layout.Column = [1 3];

            % Create DataTab
            app.DataTab = uitab(app.TabGroup);
            app.DataTab.Title = 'Data';

            % Create GridLayoutDataTab
            app.GridLayoutDataTab = uigridlayout(app.DataTab);
            app.GridLayoutDataTab.ColumnWidth = {'1x'};
            app.GridLayoutDataTab.RowHeight = {'1x'};

            % Create DataTabChildren
            app.DataTabChildren = uitabgroup(app.GridLayoutDataTab);
            app.DataTabChildren.Layout.Row = 1;
            app.DataTabChildren.Layout.Column = 1;

            % Create ALLTab
            app.ALLTab = uitab(app.DataTabChildren);
            app.ALLTab.Title = 'ALL';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.ALLTab);
            app.GridLayout4.ColumnWidth = {'1x'};
            app.GridLayout4.RowHeight = {'1x', 24};

            % Create UITable_ALL
            app.UITable_ALL = uitable(app.GridLayout4);
            app.UITable_ALL.ColumnName = {'Column 1'; 'Column 2'; 'Column 3'; 'Column 4'};
            app.UITable_ALL.RowName = {};
            app.UITable_ALL.CellSelectionCallback = createCallbackFcn(app, @UITable_ALLCellSelection, true);
            app.UITable_ALL.DisplayDataChangedFcn = createCallbackFcn(app, @UITable_ALLDisplayDataChanged, true);
            app.UITable_ALL.Layout.Row = 1;
            app.UITable_ALL.Layout.Column = 1;

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.GridLayout4);
            app.GridLayout9.ColumnWidth = {200, 200, 200, 200, '1x'};
            app.GridLayout9.RowHeight = {'1x'};
            app.GridLayout9.RowSpacing = 0;
            app.GridLayout9.Padding = [0 0 0 0];
            app.GridLayout9.Layout.Row = 2;
            app.GridLayout9.Layout.Column = 1;

            % Create AddTo_Group1
            app.AddTo_Group1 = uibutton(app.GridLayout9, 'push');
            app.AddTo_Group1.ButtonPushedFcn = createCallbackFcn(app, @AddTo_Group1ButtonPushed, true);
            app.AddTo_Group1.Layout.Row = 1;
            app.AddTo_Group1.Layout.Column = 3;
            app.AddTo_Group1.Text = 'set as Group 1';

            % Create AddTo_Group2
            app.AddTo_Group2 = uibutton(app.GridLayout9, 'push');
            app.AddTo_Group2.ButtonPushedFcn = createCallbackFcn(app, @AddTo_Group2ButtonPushed, true);
            app.AddTo_Group2.Layout.Row = 1;
            app.AddTo_Group2.Layout.Column = 4;
            app.AddTo_Group2.Text = {'set as Group 2'; ''};

            % Create DeselectButton
            app.DeselectButton = uibutton(app.GridLayout9, 'push');
            app.DeselectButton.ButtonPushedFcn = createCallbackFcn(app, @DeselectButtonPushed, true);
            app.DeselectButton.Layout.Row = 1;
            app.DeselectButton.Layout.Column = 1;
            app.DeselectButton.Text = {'Deselect'; ''};

            % Create SelectButton
            app.SelectButton = uibutton(app.GridLayout9, 'push');
            app.SelectButton.ButtonPushedFcn = createCallbackFcn(app, @SelectButtonPushed, true);
            app.SelectButton.Layout.Row = 1;
            app.SelectButton.Layout.Column = 2;
            app.SelectButton.Text = 'Select';

            % Create Group_1Tab
            app.Group_1Tab = uitab(app.DataTabChildren);
            app.Group_1Tab.Title = 'Group_1';

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.Group_1Tab);
            app.GridLayout5.ColumnWidth = {'1x'};
            app.GridLayout5.RowHeight = {'1x'};

            % Create UITable_Group_1
            app.UITable_Group_1 = uitable(app.GridLayout5);
            app.UITable_Group_1.ColumnName = {'Column 1'; 'Column 2'; 'Column 3'; 'Column 4'};
            app.UITable_Group_1.RowName = {};
            app.UITable_Group_1.Layout.Row = 1;
            app.UITable_Group_1.Layout.Column = 1;

            % Create Group_2Tab
            app.Group_2Tab = uitab(app.DataTabChildren);
            app.Group_2Tab.Title = 'Group_2';

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.Group_2Tab);
            app.GridLayout6.ColumnWidth = {'1x'};
            app.GridLayout6.RowHeight = {'1x'};

            % Create UITable_Group_2
            app.UITable_Group_2 = uitable(app.GridLayout6);
            app.UITable_Group_2.ColumnName = {'Column 1'; 'Column 2'; 'Column 3'; 'Column 4'};
            app.UITable_Group_2.RowName = {};
            app.UITable_Group_2.Layout.Row = 1;
            app.UITable_Group_2.Layout.Column = 1;

            % Create SettingsTab
            app.SettingsTab = uitab(app.TabGroup);
            app.SettingsTab.AutoResizeChildren = 'off';
            app.SettingsTab.Title = 'Settings';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.SettingsTab);
            app.GridLayout2.ColumnWidth = {350, '1x', '1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {200, '1x', '1x', '1x', '1x', '1x', '1x', '1x'};

            % Create GeneratorPanel
            app.GeneratorPanel = uipanel(app.GridLayout2);
            app.GeneratorPanel.Title = 'Generator';
            app.GeneratorPanel.Layout.Row = 1;
            app.GeneratorPanel.Layout.Column = 1;

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GeneratorPanel);
            app.GridLayout7.RowHeight = {24, 24, '1x', 32};
            app.GridLayout7.ColumnSpacing = 16;
            app.GridLayout7.Padding = [20 20 20 20];

            % Create GenerateButton
            app.GenerateButton = uibutton(app.GridLayout7, 'push');
            app.GenerateButton.Layout.Row = 4;
            app.GenerateButton.Layout.Column = 2;
            app.GenerateButton.Text = 'Generate';

            % Create SplitdatabyDropDownLabel
            app.SplitdatabyDropDownLabel = uilabel(app.GridLayout7);
            app.SplitdatabyDropDownLabel.HorizontalAlignment = 'right';
            app.SplitdatabyDropDownLabel.Layout.Row = 1;
            app.SplitdatabyDropDownLabel.Layout.Column = 1;
            app.SplitdatabyDropDownLabel.Text = 'Split data by';

            % Create SplitdatabyDropDown
            app.SplitdatabyDropDown = uidropdown(app.GridLayout7);
            app.SplitdatabyDropDown.Items = {};
            app.SplitdatabyDropDown.Layout.Row = 1;
            app.SplitdatabyDropDown.Layout.Column = 2;
            app.SplitdatabyDropDown.Value = {};

            % Create atvalueSpinnerLabel
            app.atvalueSpinnerLabel = uilabel(app.GridLayout7);
            app.atvalueSpinnerLabel.HorizontalAlignment = 'right';
            app.atvalueSpinnerLabel.Layout.Row = 2;
            app.atvalueSpinnerLabel.Layout.Column = 1;
            app.atvalueSpinnerLabel.Text = 'at value';

            % Create atvalueSpinner
            app.atvalueSpinner = uispinner(app.GridLayout7);
            app.atvalueSpinner.Layout.Row = 2;
            app.atvalueSpinner.Layout.Column = 2;

            % Create StatusLabel
            app.StatusLabel = uilabel(app.MainLayout);
            app.StatusLabel.BackgroundColor = [0.502 0.502 0.502];
            app.StatusLabel.HorizontalAlignment = 'right';
            app.StatusLabel.FontColor = [1 1 1];
            app.StatusLabel.Layout.Row = 3;
            app.StatusLabel.Layout.Column = [1 3];
            app.StatusLabel.Text = '';

            % Create GraphPanel
            app.GraphPanel = uipanel(app.MainLayout);
            app.GraphPanel.Title = 'Graph';
            app.GraphPanel.Layout.Row = 1;
            app.GraphPanel.Layout.Column = [1 3];

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.GraphPanel);
            app.GridLayout8.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.GridLayout8.RowHeight = {'1x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout8);
            title(app.UIAxes, '')
            xlabel(app.UIAxes, '')
            ylabel(app.UIAxes, '')
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = 1;

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.GridLayout8);
            title(app.UIAxes_2, '')
            xlabel(app.UIAxes_2, '')
            ylabel(app.UIAxes_2, '')
            app.UIAxes_2.Layout.Row = 1;
            app.UIAxes_2.Layout.Column = 2;

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.GridLayout8);
            title(app.UIAxes_3, '')
            xlabel(app.UIAxes_3, '')
            ylabel(app.UIAxes_3, '')
            app.UIAxes_3.Layout.Row = 1;
            app.UIAxes_3.Layout.Column = 3;

            % Create UIAxes_4
            app.UIAxes_4 = uiaxes(app.GridLayout8);
            title(app.UIAxes_4, '')
            xlabel(app.UIAxes_4, '')
            ylabel(app.UIAxes_4, '')
            app.UIAxes_4.Layout.Row = 1;
            app.UIAxes_4.Layout.Column = 4;

            % Show the figure after all components are created
            app.Sad_and_AddictionUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = stress_addiction_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.Sad_and_AddictionUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Sad_and_AddictionUIFigure)
        end
    end
end