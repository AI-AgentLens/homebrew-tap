cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1836"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1836/agentshield_0.2.1836_darwin_amd64.tar.gz"
      sha256 "189a944513d72e2cd9e7df4f75810ffc37dfbba1710ef4ce5a64eadf6bca3d88"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1836/agentshield_0.2.1836_darwin_arm64.tar.gz"
      sha256 "a0d504c3fcbe2def9602837db14399e5dcaf016f4c1204e1f9de4c98bcf4507d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1836/agentshield_0.2.1836_linux_amd64.tar.gz"
      sha256 "e613e862caa3fa51b45f6d93678fe4ade13f5eaf2dccbbdf411c9671c69372be"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1836/agentshield_0.2.1836_linux_arm64.tar.gz"
      sha256 "d21ed53e874c6fb00c2b69e8914929f41a6119f597b987524fbafa220e584190"
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
