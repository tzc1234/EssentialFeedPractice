//
//  SharedLocalisationTests.swift
//  EssentialFeedPracticeTests
//
//  Created by Tsz-Lung on 25/10/2023.
//

import XCTest
import EssentialFeedPractice

final class SharedLocalisationTests: XCTestCase {
    func test_localisedStrings_haveKeysAndValuesForAllSupportedLocalisations() {
        let table = "Shared"
        let presentationBundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        let localisationBundles = allLocalisationBundles(in: presentationBundle)
        let localisedStringKeys = allLocalisedStringKeys(in: localisationBundles, table: table)
        
        localisationBundles.forEach { (bundle, localisation) in
            localisedStringKeys.forEach { key in
                let localisedString = bundle.localizedString(forKey: key, value: nil, table: table)
                if localisedString == key {
                    let language = Locale.current.localizedString(forLanguageCode: localisation) ?? ""
                    XCTFail("Missing \(language) (\(localisation)) localised string for key: '\(key)' in table '\(table)'")
                }
            }
        }
    }
    
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
    
    // MARK: - Helpers
    
    private typealias LocalisedBundle = (bundle: Bundle, localisation: String)
    
    private func allLocalisationBundles(in bundle: Bundle,
                                        file: StaticString = #filePath,
                                        line: UInt = #line) -> [LocalisedBundle] {
        bundle.localizations.compactMap { localisation in
            guard let path = bundle.path(forResource: localisation, ofType: "lproj"),
                  let localisedBundle = Bundle(path: path) else {
                XCTFail("Couldn't find bundle for localisation: \(localisation)", file: file, line: line)
                return nil
            }
            
            return (localisedBundle, localisation)
        }
    }
    
    private func allLocalisedStringKeys(in bundles: [LocalisedBundle],
                                        table: String,
                                        file: StaticString = #filePath,
                                        line: UInt = #line) -> Set<String> {
        bundles.reduce([]) { (acc, current) in
            guard let url = current.bundle.url(forResource: table, withExtension: "strings"),
                  let strings = try? NSDictionary(contentsOf: url, error: ()),
                  let keys = strings.allKeys as? [String] else {
                XCTFail("Couldn't load localised strings for localisation: \(current.localisation)",
                        file: file,
                        line: line)
                return acc
            }
            
            return acc.union(Set(keys))
        }
    }
}
