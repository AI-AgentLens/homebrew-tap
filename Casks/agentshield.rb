cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2357"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2357/agentshield_0.2.2357_darwin_amd64.tar.gz"
      sha256 "65df2cbb684bcd7776874dfcd5718093d13c3b3fdc0b1ddd23168084873f5235"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2357/agentshield_0.2.2357_darwin_arm64.tar.gz"
      sha256 "35896ab073e63af5f07a4209d96050ab17fe2ffb82c7c9f40aadbb856e6e0ae0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2357/agentshield_0.2.2357_linux_amd64.tar.gz"
      sha256 "f52dccd5157d537adbc0ee3e120377ad0310639fa1890e5cd529638bb177774c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2357/agentshield_0.2.2357_linux_arm64.tar.gz"
      sha256 "c10945d553966e65bbcf6ebff0bad6f6f0a70e2254e8023c84d84d4d7c251a3a"
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
