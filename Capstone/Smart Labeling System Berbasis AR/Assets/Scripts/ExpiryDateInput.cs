using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;

public class ExpiryDateInputs : MonoBehaviour
{
    public TMP_InputField dayInput;
    public TMP_InputField monthInput;
    public TMP_InputField yearInput;

    private void Start()
    {
        dayInput.characterLimit = 2;
        monthInput.characterLimit = 2;
        yearInput.characterLimit = 4;

        dayInput.onValueChanged.AddListener(OnDayChanged);
        monthInput.onValueChanged.AddListener(OnMonthChanged);
        yearInput.onValueChanged.AddListener(OnYearChanged);
    }

    void OnDayChanged(string value)
    {
        if (value.Length >= 2)
            EventSystem.current.SetSelectedGameObject(monthInput.gameObject);
    }

    void OnMonthChanged(string value)
    {
        if (value.Length >= 2)
            EventSystem.current.SetSelectedGameObject(yearInput.gameObject);
    }

    void OnYearChanged(string value)
    {
        if (value.Length >= 4)
        {
            // optional: unfocus when complete
            EventSystem.current.SetSelectedGameObject(null);
        }
    }

    // optional helper if you need the full string later
    public string GetFullDate()
    {
        return $"{dayInput.text}-{monthInput.text}-{yearInput.text}";
    }
}
