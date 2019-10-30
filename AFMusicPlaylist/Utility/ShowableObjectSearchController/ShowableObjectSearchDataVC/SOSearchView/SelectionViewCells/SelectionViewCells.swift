
import UIKit


protocol SelectionViewShadows {
    func setupShadows()
    func updateShadowPath()
}


extension SelectionViewShadows where Self: UITableViewCell {
    func setupShadows() {
        contentView.layer.borderWidth = 0.2
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.shadowRadius = 3
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowColor = UIColor.gray.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    
    func updateShadowPath() {
        let width = contentView.bounds.width
        let height = contentView.bounds.height
        let rect = CGRect(x: -2, y: 3, width: width + 4, height: height + 3)
        contentView.layer.shadowPath = UIBezierPath(rect: rect).cgPath
    }
}


class PersonSelectionViewCell: PersonListCell, SelectionViewShadows {
    override class var identifier: String { return "PersonSelectionView" }
    var didSelectInfoButton: ((Person) -> Void)?
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowPath()
    }
    
    
    override func updateFrom(person: Person) {
        super.updateFrom(person: person)
        statusIV.image = UIImage(named: "icon_info")
    }
    
    
    override func setupConstraints() {
        super.setupConstraints()
        statusIV.registerExtendedClickArea(in: self, with: #selector(didClickInfoButton))
        setupShadows()
    }
    
    
    @objc private func didClickInfoButton() {
        if let nPerson = person {
            didSelectInfoButton?(nPerson)
        }
    }
}


class ContactSelectionViewCell: ContactListCell, SelectionViewShadows {
    override class var identifier: String { return "ContactUnitSelectionView" }
    override var shouldHavePhoneButton: Bool { return false }
    
    var didSelectInfoButton: ((SOContact) -> Void)?
    private var contact: SOContact?
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowPath()
    }
    
    
    override func updateFrom(contact: SOContact, model: CallableListCellModel) {
        super.updateFrom(contact: contact, model: model)
        self.contact = contact
    }
    
    
    override func setupConstraints() {
        super.setupConstraints()
        statusIV.image = UIImage(named: "icon_info")
        statusIV.registerExtendedClickArea(in: self, with: #selector(didClickInfoButton))
        setupShadows()
    }
    
    
    @objc private func didClickInfoButton() {
        if let nContact = contact {
            didSelectInfoButton?(nContact)
        }
    }
}



class CompanySelectionViewCell: ContactListCell, SelectionViewShadows {
    override class var identifier: String { return "CompanyUnitSelectionView" }
    override var shouldHavePhoneButton: Bool { return false }
    
    var didSelectInfoButton: ((Company) -> Void)?
    private var company: Company?
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowPath()
    }
    
    
    override func updateFrom(company: Company, model: CallableListCellModel) {
        super.updateFrom(company: company, model: model)
        self.company = company
    }
    
    
    override func setupConstraints() {
        super.setupConstraints()
        statusIV.image = UIImage(named: "icon_info")
        statusIV.registerExtendedClickArea(in: self, with: #selector(didClickInfoButton))
        setupShadows()
    }
    
    
    @objc private func didClickInfoButton() {
        if let nCompany = company {
            didSelectInfoButton?(nCompany)
        }
    }
}
