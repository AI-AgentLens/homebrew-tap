cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1083"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1083/agentshield_0.2.1083_darwin_amd64.tar.gz"
      sha256 "69f4313883facef04f3ff915768ed0740b3bf5cf4fca003384e0d4d6efd6d80a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1083/agentshield_0.2.1083_darwin_arm64.tar.gz"
      sha256 "4bd6943bd0bd429fd25fb379143e6f9249878a7dbcd76a0319b82bd9de7b8f6a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1083/agentshield_0.2.1083_linux_amd64.tar.gz"
      sha256 "39060c1e956c67ebe831a9d1734b2c87b19d3e819539844ae62faa1f439578a3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1083/agentshield_0.2.1083_linux_arm64.tar.gz"
      sha256 "403b32cca8299eaae503d47996a4457d6d9a15d750944f0deb3d60d15e5c5938"
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
