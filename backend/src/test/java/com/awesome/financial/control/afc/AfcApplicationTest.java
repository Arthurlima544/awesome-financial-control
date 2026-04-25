package com.awesome.financial.control.afc;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class AfcApplicationTest {

    @Test
    void main() {
        AfcApplication.main(new String[] {"--server.port=0"});
    }
}
