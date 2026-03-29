cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.184"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.184/agentshield_0.2.184_darwin_amd64.tar.gz"
      sha256 "8973a1a875831bd6af0cfe1fcff5251fd3d4bbb0d731bd718a8b689d8de2aa23"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.184/agentshield_0.2.184_darwin_arm64.tar.gz"
      sha256 "78417956c2ded884b89ff035061fd357fb671e258418bfbaad050e3e19fd84e5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.184/agentshield_0.2.184_linux_amd64.tar.gz"
      sha256 "fd9e216d19e67158432fefbc3ad4d848e6237a20626d09e2dbe68b69082c6e00"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.184/agentshield_0.2.184_linux_arm64.tar.gz"
      sha256 "d9cf51a593dd5588bf235a21a54b5c0ee2eae4b0c1d11639faebf1f77c954cdf"
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
