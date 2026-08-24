cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1951"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1951/agentshield_0.2.1951_darwin_amd64.tar.gz"
      sha256 "756c5a85c176ab6a83ddad0aa52f8effc87a3873d1a3822697cfdbc2cccf6b5e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1951/agentshield_0.2.1951_darwin_arm64.tar.gz"
      sha256 "c49b5b1a7f12bab76d92cb9d80796515640c31d708156088722d4b2a88889a49"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1951/agentshield_0.2.1951_linux_amd64.tar.gz"
      sha256 "2af372b42493c06b8c7021fbe3a6287d5e88e1a48acf64085213e3e42686b17c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1951/agentshield_0.2.1951_linux_arm64.tar.gz"
      sha256 "38df05ce5e9731372e2077fa367880f87acbb90ad815f3c7b68875233bc66151"
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
