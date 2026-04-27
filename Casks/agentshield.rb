cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.758"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.758/agentshield_0.2.758_darwin_amd64.tar.gz"
      sha256 "6d9f95db01352c07f753b00fd75de3a136636f4a6784ff982d8760fa307f932a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.758/agentshield_0.2.758_darwin_arm64.tar.gz"
      sha256 "7b2ff0472ac965fd93c1b0a31022f7fe7e801916ca910687c97ba1294be8bc74"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.758/agentshield_0.2.758_linux_amd64.tar.gz"
      sha256 "ab6a828ec9bf56a08fdc70a2c971a925f41abd6e5f8f49a49a6ec00228213f45"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.758/agentshield_0.2.758_linux_arm64.tar.gz"
      sha256 "2cfaa3ec3fd03db594366da3aba6eca96153ac27b2027086752442bad02c70d9"
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
