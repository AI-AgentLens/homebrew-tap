cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1121"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1121/agentshield_0.2.1121_darwin_amd64.tar.gz"
      sha256 "5e4cd37bd05628453fc2fafb69d8fd7e6d796b323927cb66fdb72fa92d7ee1c9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1121/agentshield_0.2.1121_darwin_arm64.tar.gz"
      sha256 "875b915a6d2aa09824481bea37efb142d7e2c48abaed094d461786a57b0cbe7a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1121/agentshield_0.2.1121_linux_amd64.tar.gz"
      sha256 "afd931064063482693df5ed285000a59d81b16594ede91a523afa629c159e45a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1121/agentshield_0.2.1121_linux_arm64.tar.gz"
      sha256 "612dc55cb94c90436e75c6a0e2a523d9a27895a521300f5675da99540e3fa2fe"
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
