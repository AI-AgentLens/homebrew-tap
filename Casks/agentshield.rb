cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2020"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2020/agentshield_0.2.2020_darwin_amd64.tar.gz"
      sha256 "b189fe3df53ef8f546332dffb8d5b9f4fddb10aae89a72a70edebf64b3622c93"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2020/agentshield_0.2.2020_darwin_arm64.tar.gz"
      sha256 "30484b97dad675f3b7c2fa242d9fa77c935efcbd5d5d914c27e91c4a815806f2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2020/agentshield_0.2.2020_linux_amd64.tar.gz"
      sha256 "1ec8d497411af71369f0742a66387dedb866e3487e54805575d8eb83b9e6d359"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2020/agentshield_0.2.2020_linux_arm64.tar.gz"
      sha256 "5c6b8af66de35396c3067e112cf47f71bab0a4b35efe26b83c6227d1495b48cb"
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
