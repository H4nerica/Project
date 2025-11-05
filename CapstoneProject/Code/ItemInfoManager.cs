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
    public GameObject infoPanel;
    public TextMeshProUGUI TMPName;
    public TextMeshProUGUI TMPExpire;
    public TextMeshProUGUI TMPTags;
    public TextMeshProUGUI TMPHint;

    public List<ItemData> items = new List<ItemData>();

    void Start()
    {
        if (infoPanel != null)
            infoPanel.SetActive(false);

        // Ensure persistent JSON exists
        string persistentPath = Path.Combine(Application.persistentDataPath, "Items.json");
        if (!File.Exists(persistentPath))
        {
            string defaultJson = Path.Combine(Application.streamingAssetsPath, "Items.json");
            if (File.Exists(defaultJson))
                File.Copy(defaultJson, persistentPath);
            else
                Debug.LogWarning("[ItemInfoManager] Default JSON not found in StreamingAssets!");
        }

        StartCoroutine(LoadItemsJson());
    }

    IEnumerator LoadItemsJson()
    {
        string path = Path.Combine(Application.persistentDataPath, "Items.json");

        UnityWebRequest request = UnityWebRequest.Get(path);
        yield return request.SendWebRequest();

        if (request.result == UnityWebRequest.Result.Success)
        {
            try
            {
                ItemDataList dataList = JsonUtility.FromJson<ItemDataList>(request.downloadHandler.text);
                if (dataList != null && dataList.items != null)
                {
                    items = new List<ItemData>(dataList.items);
                    Debug.Log($"Loaded {items.Count} items from JSON");
                }
                else
                {
                    Debug.LogWarning("JSON loaded but no items found.");
                    items = new List<ItemData>();
                }
            }
            catch (System.Exception ex)
            {
                Debug.LogError("Failed to parse JSON: " + ex.Message);
                items = new List<ItemData>();
            }
        }
        else
        {
            Debug.LogWarning("Failed to load JSON: " + request.error);
            items = new List<ItemData>();
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
        // Refresh the panel after removal
        ShowDefaultPanel(); // or call ShowItemInfo with the removed id if you want the "No Data Found" style
    }

    private void SaveToJson()
    {
        string path = Path.Combine(Application.persistentDataPath, "Items.json");
        ItemDataList wrapper = new ItemDataList { items = items.ToArray() };
        string json = JsonUtility.ToJson(wrapper, true);
        File.WriteAllText(path, json);
        Debug.Log("Saved changes to JSON: " + path);
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
