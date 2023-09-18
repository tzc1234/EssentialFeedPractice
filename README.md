# EssentialFeedPractice
## Practice the learnings from iOS Lead Essentials again.
[![](https://circleci.com/gh/tzc1234/EssentialFeedPractice.svg?style=shield)](https://circleci.com/gh/tzc1234/EssentialFeedPractice)

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

### Data:
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



