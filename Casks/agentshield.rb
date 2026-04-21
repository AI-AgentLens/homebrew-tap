cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.673"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.673/agentshield_0.2.673_darwin_amd64.tar.gz"
      sha256 "b93bf2043076d0282a10b2d269ec04e1c4c3588856a857d4d08baf5f1b5d805d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.673/agentshield_0.2.673_darwin_arm64.tar.gz"
      sha256 "0526cfbfa9d7a15449c597d54d9bc182bdcf6254162b0a28504258573a7d5d91"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.673/agentshield_0.2.673_linux_amd64.tar.gz"
      sha256 "998ce239b6779655fcb516297bfebe4cdc112bd15235da858e77c0324e14376b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.673/agentshield_0.2.673_linux_arm64.tar.gz"
      sha256 "60cca30453141fe192df0c646eef708a1525a513abbe360d55836f6ddfb6843f"
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
