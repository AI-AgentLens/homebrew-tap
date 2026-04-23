cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.697"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.697/agentshield_0.2.697_darwin_amd64.tar.gz"
      sha256 "88ac36b2ce6cc86f0a0e1deb06a00ba036d2a7b7ff870f7644434c8cae1f0c0d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.697/agentshield_0.2.697_darwin_arm64.tar.gz"
      sha256 "378a11cbe228b25c478f0964959360765defee7664ee62debbb2ac3563920436"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.697/agentshield_0.2.697_linux_amd64.tar.gz"
      sha256 "fe664c6778b9873e96a052d2206da02454649ad0b129e5c56a15c2b9f79379db"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.697/agentshield_0.2.697_linux_arm64.tar.gz"
      sha256 "f2a3488a06bc5f65132e8c6382d135905e694769887612fe51bdac5467bcfef5"
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
