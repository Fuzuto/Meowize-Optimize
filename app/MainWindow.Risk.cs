using System.Windows;
using System.Windows.Automation;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Media;
using Wpf.Ui.Controls;
using Button = Wpf.Ui.Controls.Button;
using TextBlock = System.Windows.Controls.TextBlock;
using static AioOptimize.Localizer;

namespace AioOptimize;

public partial class MainWindow
{
    private sealed record RiskDisplay(string Key, string Symbol, string Brush, string Fill)
    {
        internal string Label => T(Key);
        internal string Description => T(Key + "Help");
    }

    private static readonly Dictionary<TaskRisk, RiskDisplay> RiskLevels = new()
    {
        [TaskRisk.Safe] = new("Safe", "ShieldCheckmark24", "RiskSafe", "RiskSafeFill"),
        [TaskRisk.Caution] = new("Caution", "Warning24", "RiskCaution", "RiskCautionFill"),
        [TaskRisk.Warning] = new("Warning", "ErrorCircle24", "RiskWarning", "RiskWarningFill")
    };

    private readonly Dictionary<TaskRisk, TextBlock> _riskCounts = new();

    private static string RiskHelp(Operation operation) =>
        operation.DisplayRiskNote is { Length: > 0 } note ? note : RiskLevels[operation.Risk].Description;

    private static Border RiskBadge(TaskRisk risk, string? note = null)
    {
        var level = RiskLevels[risk];
        var contents = new StackPanel { Orientation = Orientation.Horizontal, VerticalAlignment = VerticalAlignment.Center };
        contents.Children.Add(RiskIcon(risk));
        var label = Label(level.Label, "MutedText");
        label.FontSize = 11;
        label.FontWeight = FontWeights.SemiBold;
        label.Margin = new(5, 0, 0, 0);
        label.VerticalAlignment = VerticalAlignment.Center;
        label.SetResourceReference(ForegroundProperty, level.Brush);
        contents.Children.Add(label);

        var badge = new Border { Child = contents, CornerRadius = new(10), Padding = new(7, 4, 8, 4),
            ToolTip = note is null ? level.Description : $"{level.Description}\n{note}", VerticalAlignment = VerticalAlignment.Center };
        badge.SetResourceReference(Border.BackgroundProperty, level.Fill);
        AutomationProperties.SetName(badge, level.Label);
        return badge;
    }

    private static SymbolIcon RiskIcon(TaskRisk risk)
    {
        var level = RiskLevels[risk];
        var icon = Symbol(level.Symbol, 15);
        icon.SetResourceReference(ForegroundProperty, level.Brush);
        return icon;
    }

    private UniformGrid BuildRiskCounts()
    {
        var grid = new UniformGrid { Columns = 3, VerticalAlignment = VerticalAlignment.Center };
        foreach (var (risk, level) in RiskLevels)
        {
            var counter = Label("", "SectionLabel");
            counter.FontSize = 23;
            counter.Margin = new(0, 4, 0, 0);
            counter.SetResourceReference(ForegroundProperty, level.Brush);
            AutomationProperties.SetAutomationId(counter, "Selected_" + risk);
            _riskCounts[risk] = counter;
            var stack = new StackPanel();
            var label = RiskBadge(risk);
            label.HorizontalAlignment = HorizontalAlignment.Left;
            stack.Children.Add(label);
            stack.Children.Add(counter);
            var tile = new Border { Child = stack, CornerRadius = new(11), Padding = new(8, 8, 8, 7), Margin = new(6, 0, 0, 0) };
            tile.SetResourceReference(Border.BackgroundProperty, "GlassInset");
            grid.Children.Add(tile);
        }
        return grid;
    }

    private Button TaskInfoButton(Operation operation, bool batch = false)
    {
        var button = ActionButton("", ControlAppearance.Transparent, (_, _) =>
        {
            var run = batch ? T(operation.Mode == "settings" ? "TaskUseBatchSettings" : "TaskUseBatch") :
                operation.Id == "btnApplyDns" ? T("TaskUseDns") :
                T("TaskUseAction", operation.Mode == "settings" ? T("OpenSettings") : OperationLabel(operation.Id));
            var body = DescribeRisk(operation, run);
            if (operation.Admin)
                body.Children.Add(Label(T("TaskRequiresAdmin"), "MutedText"));
            if (UnavailableReason(operation.Id) is { } reason)
                body.Children.Add(Label(reason, "MutedText"));
            var reference = operation.Reference;
            var link = ReferenceLink(T(reference.Kind), reference.Source, reference.Kind, "BodyText");
            link.Margin = new(0, 9, 0, 0);
            body.Children.Add(link);
            Dialog(operation.DisplayTitle, body);
        });
        button.Icon = Symbol("Info24", 16);
        button.Padding = new(7);
        button.MinHeight = 32;
        button.MinWidth = 32;
        button.VerticalAlignment = VerticalAlignment.Center;
        button.Margin = new(4, 0, 4, 0);
        button.ToolTip = T("TaskDetails");
        AutomationProperties.SetAutomationId(button, "Info_" + operation.Id);
        AutomationProperties.SetName(button, T("TaskDetailsFor", operation.DisplayTitle));
        AutomationProperties.SetHelpText(button, operation.DisplayDetails);
        return button;
    }

    private static StackPanel DescribeRisk(Operation operation, string? context = null)
    {
        var body = new StackPanel();
        var badge = RiskBadge(operation.Risk, operation.DisplayRiskNote);
        badge.HorizontalAlignment = HorizontalAlignment.Left;
        badge.Margin = new(0, 0, 0, 9);
        body.Children.Add(badge);
        if (!string.IsNullOrWhiteSpace(context))
        {
            var intro = Label(context, "BodyText");
            intro.Margin = new(0, 0, 0, 8);
            body.Children.Add(intro);
        }
        body.Children.Add(Label(operation.DisplayDetails, "BodyText"));
        if (operation.Restart)
        {
            var restart = Label(T("TaskMayRestart"), "MutedText");
            restart.Margin = new(0, 8, 0, 0);
            body.Children.Add(restart);
        }
        if (operation.DisplayRiskNote is { Length: > 0 } note)
        {
            var riskNote = Label(note, "MutedText");
            riskNote.Margin = new(0, 8, 0, 0);
            riskNote.SetResourceReference(ForegroundProperty, RiskLevels[operation.Risk].Brush);
            body.Children.Add(riskNote);
        }
        return body;
    }
}
