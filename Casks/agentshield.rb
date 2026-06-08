cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1249"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1249/agentshield_0.2.1249_darwin_amd64.tar.gz"
      sha256 "3721ff381b944f6eb7615e87b251aea8e4433154f4cfca92eec2df7aeadcfb1e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1249/agentshield_0.2.1249_darwin_arm64.tar.gz"
      sha256 "d3f07c5ade06272eb8aa929a25d84879557aa5383d42dac6b22a7a188b3e8239"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1249/agentshield_0.2.1249_linux_amd64.tar.gz"
      sha256 "531c00c65bf431deedcfe8c334106a765ec719f489a69b6fe660668401247c5a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1249/agentshield_0.2.1249_linux_arm64.tar.gz"
      sha256 "88af8d3f1e7f9747be04bad23f70bef8a19e91f0b7736059321815727b70f3cf"
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
