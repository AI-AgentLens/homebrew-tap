cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1662"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1662/agentshield_0.2.1662_darwin_amd64.tar.gz"
      sha256 "4fda1fcd8166317fc8ac1e404b0fb92362377a0c4915fdcda27b2bbaf0b55ed3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1662/agentshield_0.2.1662_darwin_arm64.tar.gz"
      sha256 "436dceef32f28dc59223a298fd33d2c53d1a4fc9f5622a29d87fce7ec8a14fcb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1662/agentshield_0.2.1662_linux_amd64.tar.gz"
      sha256 "761ef876b50ecb46fda5f21219abacd450dd5faa84dcb254da3c5b80c57152d8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1662/agentshield_0.2.1662_linux_arm64.tar.gz"
      sha256 "e7a8692133f8cd5bde1ef316832c34899f0f4c1263b3329b2916a558e8c3f6e7"
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
