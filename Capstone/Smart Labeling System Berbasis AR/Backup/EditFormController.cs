using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using TMPro;
using System.IO;

[System.Serializable]
public class ItemData
{
    public string id;
    public string name;
    public string expireIn;
    public string tag;
}

[System.Serializable]
public class ItemDataList
{
    public ItemData[] items;
}

public class ItemInfoManager : MonoBehaviour
{
    [Header("UI References")]
    public GameObject infoPanel;
    public TextMeshProUGUI TMPName;
    public TextMeshProUGUI TMPExpire;
    public TextMeshProUGUI TMPTags;
    public TextMeshProUGUI TMPHint;

    [Header("Days Left Reference")]
    public DaysLeft daysLeft;  // assign in inspector

    [Header("Data")]
    public List<ItemData> items = new List<ItemData>();

    private string savePath;

    void Start()
    {
        if (infoPanel != null)
            infoPanel.SetActive(false);

        savePath = Path.Combine(Application.persistentDataPath, "Items.json");
        string defaultPath = Path.Combine(Application.streamingAssetsPath, "Items.json");

        // ✅ Only copy the default JSON once (first launch only)
        if (!File.Exists(savePath))
        {
            if (File.Exists(defaultPath))
            {
                File.Copy(defaultPath, savePath);
                Debug.Log("[ItemInfoManager] Default Items.json copied to persistentDataPath");
            }
            else
            {
                Debug.LogWarning("[ItemInfoManager] Default JSON not found in StreamingAssets!");
                File.WriteAllText(savePath, JsonUtility.ToJson(new ItemDataList { items = new ItemData[0] }, true));
            }
        }

        // ✅ Always load from the persistent save file
        LoadItemsJson();
    }

    // 🔹 Read JSON directly from persistent path (no web request)
    private void LoadItemsJson()
    {
        if (File.Exists(savePath))
        {
            try
            {
                string json = File.ReadAllText(savePath);
                ItemDataList dataList = JsonUtility.FromJson<ItemDataList>(json);

                if (dataList != null && dataList.items != null)
                {
                    items = new List<ItemData>(dataList.items);
                    Debug.Log($"✅ Loaded {items.Count} items from JSON.");
                }
                else
                {
                    items = new List<ItemData>();
                    Debug.LogWarning("⚠️ JSON loaded but contains no valid items.");
                }
            }
            catch (System.Exception ex)
            {
                Debug.LogError("❌ Failed to read JSON: " + ex.Message);
                items = new List<ItemData>();
            }
        }
        else
        {
            items = new List<ItemData>();
            Debug.LogWarning("⚠️ No save file found at " + savePath);
        }
    }

    public void ShowItemInfo(string scannedID)
    {
        if (string.IsNullOrEmpty(scannedID))
        {
            if (infoPanel != null)
                infoPanel.SetActive(false);
            return;
        }

        ItemData data = GetItemByID(scannedID);

        if (data != null)
        {
            infoPanel.SetActive(true);
            TMPName.text = string.IsNullOrEmpty(data.name) ? "Unnamed Item" : data.name;
            TMPExpire.text = string.IsNullOrEmpty(data.expireIn) ? "No Expiry" : data.expireIn;

            // <-- DaysLeft hookup
            if (daysLeft != null && !string.IsNullOrEmpty(data.expireIn))
                daysLeft.SetExpiry(data.expireIn);

            TMPTags.text = string.IsNullOrEmpty(data.tag) ? "No Tag" : data.tag;
        }
        else
        {
            if (infoPanel != null)
            {
                infoPanel.SetActive(true);
                TMPName.text = "No Data Found";
                TMPExpire.text = "-";
                TMPTags.text = "-";
            }
        }
    }

    public ItemData GetItemByID(string id)
    {
        if (items == null) return null;
        return items.Find(x => x.id == id);
    }

    public void SaveItemInfo(ItemData updatedItem)
    {
        if (items == null || updatedItem == null) return;

        int index = items.FindIndex(x => x.id == updatedItem.id);
        if (index >= 0)
            items[index] = updatedItem;
        else
            items.Add(updatedItem);

        SaveToJson();
    }

    public void RemoveItemInfo(string id)
    {
        if (items == null) return;

        ItemData data = GetItemByID(id);
        if (data != null)
        {
            data.name = "";
            data.expireIn = "";
            data.tag = "";
        }

        ShowDefaultPanel();
    }

    private void SaveToJson()
    {
        ItemDataList wrapper = new ItemDataList { items = items.ToArray() };
        string json = JsonUtility.ToJson(wrapper, true);
        File.WriteAllText(savePath, json);
        Debug.Log("💾 Saved changes to: " + savePath);
    }

    public void ShowDefaultPanel()
    {
        if (infoPanel != null)
            infoPanel.SetActive(true);

        if (TMPName != null) TMPName.text = "Unknown Item";
        if (TMPExpire != null) TMPExpire.text = "—";
        if (TMPTags != null) TMPTags.text = "No Tag";
    }
}
