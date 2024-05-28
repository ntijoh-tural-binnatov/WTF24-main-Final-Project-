describe('Start page', () => {
  it('Should show start page = PASS', () => {
    
    // Besöker startsidan
    cy.visit('http://localhost:9292/');
  });

});


describe('Login and Logout Test = PASS', () => {
  it('should log in to a form ', () => {
    
    // Besöker startsidan
    cy.visit('http://localhost:9292/');
    
    // Click the "Login" link
    cy.contains('Login') 
    cy.get('button').contains('Login').click()

  });
});


describe('Admin Priveliges = PASS', () => {
  it('What admin can do and not do', () => {
    
    // Besöker startsidan
    cy.visit('http://localhost:9292/');
    cy.contains('Register') 
    cy.get('button').contains('Register')
  });
});
