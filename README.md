# EssentialFeedPractice
## Practice the learnings from iOS Lead Essentials again.
[![CI-iOS](https://github.com/tzc1234/EssentialFeedPractice/actions/workflows/CI-iOS.yml/badge.svg)](https://github.com/tzc1234/EssentialFeedPractice/actions/workflows/CI-iOS.yml)

## Use Cases

### Load Feed From Remote Use Case

#### Data:
- URL

#### Primary course (happy path):
1. Execute "Load Image Feed" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates image feed from valid data.
5. System delivers image feed.

#### Invalid data - error course (sad path):
1. System delivers invalid data error.

#### No conectivity - error course (sad path):
1. System delivers connectivity error.

---

### Load Feed Image Data From Remote Use Case

#### Data:
- URL

#### Primary course (happy path):
1. Execute "Load Image Data" command with above data.
2. System downloads data from the URL.
3. System validates download data.
4. System delivers image data.

#### Cancel course:
1. System does not deliver image data nor error.

#### Invalid data - error course (sad path):
1. System delivers imvalid data error.

#### No connectivity - error course (sad path):
1. System delivers connectivity error.

---

### Load Feed From Cache Use Case

#### Date:
- URL

#### Primary course:
1. Execute "Load Image Feed" command with above data.
2. System retrieves feed data from cache.
3. System validates cache is less than seven days old.
4. System creates image feed from cached data.
5. System delivers image feed.

#### Retrieval error course (sad path):
1. System delivers error.

#### Expired cache course (sad path):
1. System delivers no feed images.

#### Empty cache course (sad path):
1. System delivers no feed images.

---

### Load Feed Image Data From Cache Use Case

#### Data: 
- URL

#### Primary course (happy path):
1. Execute "Load Image Data" command with above data.
2. System retrieves data from the cache.
3. System delivers cached image data.

#### Cancel course:
1. System does not deliver image data nor error.

#### Retrieval error course (sad path):
1. System delivers error.

#### Empty cache course (sad path):
1. System deliver not found error.

---

### Validate Feed Cache Use Case

#### Primary course:
1. Execute "Validate Cache" command with above data.
2. System retrieves feed data from cache.
3. System validates cache is less than seven days old.

#### Retrieval error course (sad path):
1. System deletes cache.

#### Expired cache course (sad path):
1. System deletes cache.

---

### Cache Feed Use Case

#### Data:
- Image Feed

#### Primary course:
1. Execute "Save Image Feed" command with above data.
2. System deletes old cache data.
3. System encodes image feed.
4. System timestamps the new cache.
5. System saves new cache data.

#### Deleting error course (sad path):
1. System delivers error.

#### Saving error course (sad path):
1. System delivers error.

---

### Cache Feed Image Data Use Case

#### Data:
- Image Data

#### Primary course (happy path):
1. Execute "Save Image Data" command with above data.
2. System caches image data.
3. system delivers success message.

#### Saving error course (sad path):
1. System delivers error.

### Load Image Comments From Remote Use Case

#### Data: 
- ImageID

#### Primary course (happy path):
1. Execute "Load Image Comments" command with above data.
2. System loads data from remote service.
3. System validates data.
4. System creates comments from valid data.
5. Systme delivers comments.

#### Invalid data - error course (sad path):
1. System delivers invalid data error.

#### No connectivity - error course (sad path):
1. System delivers connectivity error.

---

## Model Specs

### Feed Image

| Property | Type |
-----------|------|
|`id`|`UUID`|
|`description`|`String?`|
|`location`|`String?`|
|`url`|`URL`|

### Payload contract

```
GET /feed

200 RESPONSE

{
	"items": [
		{
			"id": "a UUID",
			"description": "a description",
			"location": "a location",
			"image": "https://a-image.url",
		},
		{
			"id": "another UUID",
			"description": "another description",
			"image": "https://another-image.url"
		},
		{
			"id": "even another UUID",
			"location": "even another location",
			"image": "https://even-another-image.url"
		},
		{
			"id": "yet another UUID",
			"image": "https://yet-another-image.url"
		}
		...
	]
}
```
---

### Image Comment

| Property | Type |
|----------|------|
| `id` | `UUID`|
| `message` | `String`|
| `created_at` | `Date` (ISO8601 String)|
| `author` | `CommentAuthorObject` |

### Image Comment Author

| Property | Type |
|----------|------|
| `username` | `String` |

### Payload contract

```
GET /image/{image-id}/comments
2xx Response

{
	"items": [
		{
			"id": "a UUID",
			"message": "a message",
			"created_at": "2020-05-20T11:24:59+0000",
			"author": {
				"username": "a username"
			}
		},
		{
			"id": "another UUID",
			"message": "another message",
			"created_at": "2020-05-19T14:23:53+0000",
			"author": {
				"username": "another username"
			}
		},
		...
	]
}
```