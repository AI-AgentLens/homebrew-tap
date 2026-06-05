cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1215"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1215/agentshield_0.2.1215_darwin_amd64.tar.gz"
      sha256 "dbae2b2fb7e196dfd557083397fd1a12d97ab540a36f25c2d9b887c65b115d67"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1215/agentshield_0.2.1215_darwin_arm64.tar.gz"
      sha256 "4c75df9b1cce6a931899b6499c25f40d9722d3d60332d82d8457c2b844c68828"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1215/agentshield_0.2.1215_linux_amd64.tar.gz"
      sha256 "aea69db43bf0d62ac293aa41ea3cef79eee9c96145e743035b26be204d5cb141"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1215/agentshield_0.2.1215_linux_arm64.tar.gz"
      sha256 "3be13e7aae1bf53194b86cb937e2509c1867f05643e4a2dd37c7a7cf3cea22d2"
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
