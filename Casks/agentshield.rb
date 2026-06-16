cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1344"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1344/agentshield_0.2.1344_darwin_amd64.tar.gz"
      sha256 "c9978c9e8893f26400d2aefafe3d6600ad85e665502990b75056cb98bd34c719"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1344/agentshield_0.2.1344_darwin_arm64.tar.gz"
      sha256 "e863708c3aac301c9fa02a505bf7395a3ddce62ba90625cb6acddd0fe97350df"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1344/agentshield_0.2.1344_linux_amd64.tar.gz"
      sha256 "e30dbbbb7eca44fe24605f1941c8320d53968aeb621549aacafd1094591ffddc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1344/agentshield_0.2.1344_linux_arm64.tar.gz"
      sha256 "bede198ea8d34286c34f9117e82c0b585c39b676ea9926aa9ac9fc5bbc88b97b"
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
