cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1917"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1917/agentshield_0.2.1917_darwin_amd64.tar.gz"
      sha256 "4f9c06e6a66630f9ebfb94c18a2ec9eaaf9a18924de0f709f0b2d53ebf244f96"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1917/agentshield_0.2.1917_darwin_arm64.tar.gz"
      sha256 "671f15d965b433ec87a63e511b7ad5bb72fbfb96f1b740cbef054827a9d67b4d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1917/agentshield_0.2.1917_linux_amd64.tar.gz"
      sha256 "41a8bcdb6a90e275cbc52199a5eb1332708b9c03d8e19784d5f663ec0ee3ce30"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1917/agentshield_0.2.1917_linux_arm64.tar.gz"
      sha256 "460eea11e7792b5fed0be63640138b2c6ab1719ef4ff7ad0f318b4e1b6a18aa9"
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
