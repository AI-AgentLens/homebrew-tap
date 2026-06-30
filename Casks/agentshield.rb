cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1499"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1499/agentshield_0.2.1499_darwin_amd64.tar.gz"
      sha256 "a9d563bfa9691db767b5f16a5dfa5bf6c51e6ba81f9f545355e3979bb421da9f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1499/agentshield_0.2.1499_darwin_arm64.tar.gz"
      sha256 "4bec34ec61945df736abbdb7494272e09bde1cd14e954213e38189d6ee929d0f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1499/agentshield_0.2.1499_linux_amd64.tar.gz"
      sha256 "2a0ae3ce5bbec9489627c504be7223f41df9ea52603a63d109ef7bf905cfee5a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1499/agentshield_0.2.1499_linux_arm64.tar.gz"
      sha256 "a18bc1cdc22b1eddd4e34ea7ac7b3650796ab2ea301f5e3f9600283c0bbcc9db"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
