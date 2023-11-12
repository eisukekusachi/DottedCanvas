//
//  ProjectListViewModelUpsertTests.swift
//  DottedCanvasTests
//
//  Created by Eisuke Kusachi on 2023/09/17.
//

import XCTest
@testable import DottedCanvas

final class ProjectListViewModelUpsertTests: XCTestCase {

    var viewModel: ProjectListViewModel!

    var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        return formatter
    }()

    let projectName = "TestProject0"
    let mainImageThumbnail: UIImage? = UIImage(systemName: "pencil")
    let latestUpdateDate: Date = Date()

    override func setUpWithError() throws {
        let initialProjects = [ProjectDataInList(projectName: projectName,
                                                 thumbnail: mainImageThumbnail,
                                                 latestUpdateDate: latestUpdateDate)]
        viewModel = ProjectListViewModel(projects: initialProjects)
    }

    func testAddingNewProjectData() {
        // Initial count should be 1
        XCTAssertEqual(viewModel.projects.count, 1)

        let newProjectName = "TestProject1"
        let newMainImageThumbnail: UIImage? = UIImage(systemName: "pencil")
        let newLatestUpdateDate: Date = Date()

        let newProjectData = ProjectData(mainImageThumbnail: newMainImageThumbnail,
                                         subImageLayers: [SubImageData()],
                                         subImageLayerIndex: 0,
                                         latestUpdateDate: newLatestUpdateDate)

        // Add new data
        viewModel.upsertProjectDataInList(newProjectData, projectName: newProjectName)

        // After adding, count should be 2
        XCTAssertEqual(viewModel.projects.count, 2)

        // Verify the new data
        XCTAssertEqual(viewModel.projects[1].projectName, 
                       newProjectName)
        XCTAssertEqual(viewModel.projects[1].thumbnail, 
                       newMainImageThumbnail)
        XCTAssertEqual(formatter.string(from: viewModel.projects[1].latestUpdateDate),
                       formatter.string(from: newLatestUpdateDate))
    }

    func testUpdatingExistingProjectData() {
        // Initial count should be 1
        XCTAssertEqual(viewModel.projects.count, 1)

        let newMainImageThumbnail: UIImage? = UIImage(systemName: "pencil")
        let newLatestUpdateDate: Date = Date()

        let newProjectData = ProjectData(mainImageThumbnail: newMainImageThumbnail,
                                         subImageLayers: [SubImageData()],
                                         subImageLayerIndex: 0,
                                         latestUpdateDate: newLatestUpdateDate)

        // Update existing data
        viewModel.upsertProjectDataInList(newProjectData, projectName: projectName)

        // Count should remain 1
        XCTAssertEqual(viewModel.projects.count, 1)

        // Verify that the data has been updated
        XCTAssertEqual(viewModel.projects[0].projectName, 
                       projectName)
        XCTAssertEqual(viewModel.projects[0].thumbnail,
                       newMainImageThumbnail)
        XCTAssertEqual(formatter.string(from: viewModel.projects[0].latestUpdateDate),
                       formatter.string(from: newLatestUpdateDate))
    }
}
