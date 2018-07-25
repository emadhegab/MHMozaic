//
//  TileLayout.swift
//  HeyBeach
//
//  Created by Mohamed Hegab on 5/10/18.
//  Copyright © 2018 Mohamed Emad Hegab. All rights reserved.
//

import UIKit


class MHMozaicLayout: UICollectionViewLayout {

    fileprivate let numberOfColumns = 3
    fileprivate let cellPadding: Int = 6
    var cache = [UICollectionViewLayoutAttributes]()

    fileprivate var contentHeight: Int = 0
    fileprivate var contentWidth: Int {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return Int(collectionView.bounds.width - (insets.left + insets.right))
    }

    var columnWidth: Int {
        return contentWidth / numberOfColumns
    }
    var defualtCellHeight: Int {
        return columnWidth
    }

    //overriding layout methods
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    // prepare the layout for all items before display
    // TODO: // need to make the preparation for the newly added items only instead of going through all the items every time.


    override func prepare() {

        guard  let collectionView = collectionView else {
            return
        }

        // dictionary for indecating the size expecting from each schema item
        // every item in this dictionary will have value tuple of (n, m)
        // n here means it will take n colums and m will mean it takes m rows
        var photOrientationDict = [
                PhotoOrientation.fullLandscape  : (3,1),
                PhotoOrientation.landscape : (2,1),
                PhotoOrientation.portrait : (1,2),
                PhotoOrientation.square : (1,1)
            ]

        var grid =  [[Int]]() // We will use this grid to mark how much row we may need in the next rows..
        var xOffset = [Int]() // the purpose of this xOffset is to have static refrence that show the starting x points
        var yOffset = [Int](repeating: 0, count: numberOfColumns) /* The yOffset array tracks the y-position for every column. You initialize each value in yOffset to 0, since this is the offset of the first item in each column. */


        for columnIndex in 0 ..< numberOfColumns {
            xOffset.append(columnIndex * columnWidth)
        }
        var columnIndex = 0
        var rowIndex = 0
        var schemeIndex = 0
        var schemasArray = SchemaFactory.generateSchemas()

        for index in 0 ..< collectionView.numberOfItems(inSection: 0) {

            let scheme = schemasArray[schemeIndex]
            schemeIndex =  schemeIndex > schemasArray.count - 2 ? 0 : schemeIndex + 1

            let colSpan = (photOrientationDict[scheme]?.0)! // how much cells needed in column for this item
            let rowSpan = (photOrientationDict[scheme]?.1)! // how much cells needed in row for this item

            //Start Create the frame for cell
            let width =  columnWidth * colSpan
            let paddingMargin = scheme == PhotoOrientation.portrait ? 4 : 2
            let height = defualtCellHeight * rowSpan + cellPadding * paddingMargin
            columnIndexAndRowIndexResetter(&columnIndex, colSpan, &rowIndex)

            expandGrid(index, &grid)
            if rowSpan == photOrientationDict[PhotoOrientation.portrait]! .1 { // rowspan == 2 is basically the portrait
                grid[rowIndex + 1][columnIndex] = 1
                // occupy the cell of the grid on the next row to avoid intersection for the other items on the next row
            }

            if grid[rowIndex][columnIndex] == 1 {
                columnIndex += 1
                columnIndexAndRowIndexResetter(&columnIndex, colSpan, &rowIndex)
            }

            let frame = CGRect(x: xOffset[columnIndex], y: yOffset[columnIndex], width:  width, height: height)

            // in this foor loop we accumlate the height of all the rows that involved in this items, to a Y to start from on next items in next rows
            for index in columnIndex ..< columnIndex + Int(colSpan) {
                yOffset[index] = yOffset[index] + height
            }

            columnIndex += Int(colSpan) // increment the column index based on the width of the item
            let insetFrame = frame.insetBy(dx: CGFloat(cellPadding), dy: CGFloat(cellPadding))


            // final step .. to append this frame into the attributes to iterate on it @ layoutAttributesForItem method
            let indexPath = IndexPath(item: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)

            // expand the content height
            contentHeight = max(contentHeight, Int(insetFrame.maxY))
        }

    }

    override  func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }

    fileprivate func columnIndexAndRowIndexResetter(_ columnIndex: inout Int, _ colSpan: Int, _ rowIndex: inout Int) {

        // we need to reset the indieces whenever it reach the limit, just to move to the next row safely
        if columnIndex > (numberOfColumns - Int(colSpan))  {
            columnIndex = 0
            rowIndex =  rowIndex + 1
        }
    }

    fileprivate func expandGrid(_ index: Int, _ grid: inout [Array<Int>]) {
        if index == 0 || index % 6 == 0 { // expand the grid on every page
            let appendableArray =  Array(repeating: Array(repeating: 0, count: 3), count: numberOfColumns)
            grid.append(contentsOf: appendableArray)
        }
    }

}
